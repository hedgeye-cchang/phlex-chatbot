# frozen_string_literal: true

require_relative "client/server_sent_events"
require_relative "client/web_socket"

module Phlex
  module Chatbot
    class Channel
      attr_reader :conversator, :clients, :channel_id

      def initialize(channel_id)
        @conversator = Phlex::Chatbot.conversator(channel_id: channel_id)
        @channel_id  = channel_id
        @clients     = Concurrent::Set.new
      end

      def send_ack!(message:)
        args = conversator.contextualize(message: message, from_user: true)
        send_event(:resp, data: [{ cmd: "append", element: Chat::Message.new(**args).call }])
      end

      def send_failure!(error, uid: nil)
        Chatbot.logger.error error
        message = if error.respond_to?(:message) && Phlex::Chatbot.allow_error_messages?
                    error.message
                  elsif error.is_a?(String)
                    error
                  else
                    "An error occurred"
                  end
        args = conversator.contextualize(message: message, from_user: false, uid: uid)
        send_event(
          :resp,
          data: [
            { cmd: "delete", selector: "#current_status" },
            { cmd: "append", element: Chat::Message.new(**args).call },
          ],
        )
      end

      def send_partial_response!(message:, status_message:, format: nil, uid: nil)
        args = conversator.contextualize(
          message: message,
          from_user: false,
          status_message: status_message,
          format: format,
          uid: uid,
        )
        send_event(
          :resp,
          data: [
            { cmd: "delete", selector: "#current_status" },
            { cmd: "append", element: Chat::Message.new(**args).call },
          ],
        )
      end

      def send_response!(message:, sources: nil, format: nil, uid: nil)
        args = conversator.contextualize(message: message, format: format, from_user: false, sources: sources, uid: uid)
        send_event(
          :resp,
          data: [
            { cmd: "delete", selector: "#current_status" },
            { cmd: "append", element: Chat::Message.new(**args).call },
          ],
        )
      end

      def send_status!(message:)
        send_event(
          :resp,
          data: [
            { cmd: "delete", selector: "#current_status" },
            { cmd: "append", element: ChatbotThinking.new(message).call },
          ],
        )
      end

      def start_conversation!(data)
        conversator.call(self, data, channel_id)
      rescue StandardError => e
        send_failure!(e)
      end

      def subscribe(client)
        @clients << client
        send_event(:joined, data: [])
      end

      protected

      def send_event(event, data:)
        removals = Set.new
        clients.each do |client|
          # one of ServerSentEvents or WebSocket
          client.send_event(event, data)
        rescue Errno::EPIPE => _e
          removals << client
        end
        removals.each do |e|
          e.close rescue nil # rubocop:disable Style/RescueModifier
          clients.delete(e)
        end
        Switchboard.destroy(channel_id) if clients.empty?
      end
    end
  end
end

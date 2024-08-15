# frozen_string_literal: true

require_relative "lib/phlex/chatbot/version"

Gem::Specification.new do |spec|
  spec.name = "phlex-chatbot"
  spec.version = Phlex::Chatbot::VERSION
  spec.authors = ["Hedgeye Risk Management, LLC"]
  spec.email = ["developers@hedgeye.com"]

  spec.summary = "summarize it"
  spec.description = "Write a longer description or delete this line."
  spec.homepage = "https://github.com/hedgeyedev/phlex-chatbot"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["allowed_push_host"] = "gems.hedgeye.cloud"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ dist/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

# frozen_string_literal: true

require_relative "lib/active_image_persist/version"

Gem::Specification.new do |spec|
  spec.name          = "active_image_persist"
  spec.version       = ActiveImagePersist::VERSION
  spec.authors       = ["gengosha"]
  spec.email         = ["sugi@gengosha.co.jp"]

  spec.summary       = "This gem provides you an interactive way to deal with image files lost from validation error."
  spec.description   = "This gem is intended to help with image files lost or corruption in the view from validation error with active storage. ActiveStorage's installation is required."
  spec.homepage      = "https://github.com/gengosha/active_image_persist"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/gengosha/active_image_persist"
  spec.metadata["changelog_uri"] = "https://github.com/gengosha/active_image_persist"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end

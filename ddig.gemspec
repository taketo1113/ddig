# frozen_string_literal: true

require_relative "lib/ddig/version"

Gem::Specification.new do |spec|
  spec.name = "ddig"
  spec.version = Ddig::VERSION
  spec.authors = ["Taketo Takashima"]
  spec.email = ["t.taketo1113@gmail.com"]

  spec.summary = "DNS lookup utility for Ruby"
  spec.description = "DNS lookup utility for Ruby"
  spec.homepage = "https://github.com/taketo1113/ddig"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/taketo1113/ddig"
  spec.metadata["changelog_uri"] = "https://github.com/taketo1113/ddig"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "resolv", "~> 0.3.0"
end

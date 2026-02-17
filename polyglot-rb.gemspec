# frozen_string_literal: true

require_relative "lib/polyglot/version"

Gem::Specification.new do |spec|
  spec.name = "polyglot-rb"
  spec.version = Polyglot::VERSION
  spec.authors = ["Polyglot Contributors"]
  spec.email = []

  spec.summary = "Ruby bindings for polyglot-sql"
  spec.description = "SQL dialect translator supporting 30+ databases — Ruby bindings via Magnus"
  spec.homepage = "https://github.com/catkins/polyglot-rb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/catkins/polyglot-rb"
  spec.metadata["changelog_uri"] = "https://github.com/catkins/polyglot-rb/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir[
    "lib/**/*.rb",
    "ext/**/*.{rb,rs,toml}",
    "Cargo.toml",
    "LICENSE",
    "README.md"
  ]

  spec.bindir = "bin"
  spec.require_paths = ["lib"]
  spec.extensions = ["ext/polyglot_rb/extconf.rb"]

  spec.add_dependency "rb_sys", "~> 0.9"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rake-compiler", "~> 1.2"
  spec.add_development_dependency "rspec", "~> 3.12"
end

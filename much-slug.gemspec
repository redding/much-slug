# frozen_string_literal: true

# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "much-slug/version"

Gem::Specification.new do |gem|
  gem.name        = "much-slug"
  gem.version     = MuchSlug::VERSION
  gem.authors     = ["Kelly Redding", "Collin Redding"]
  gem.email       = ["kelly@kellyredding.com", "collin.redding@me.com"]
  gem.summary     = "Friendly, human-readable identifiers for database records."
  gem.description = "Friendly, human-readable identifiers for database records."
  gem.homepage    = "https://github.com/redding/much-slug"
  gem.license     = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = "~> 2.5"

  gem.add_dependency("much-plugin", ["~> 0.2.1"])

  gem.add_development_dependency("assert", ["~> 2.19.2"])
  gem.add_development_dependency("ardb",   ["~> 0.29.1"])
end

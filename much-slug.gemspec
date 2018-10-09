# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
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
  gem.license     = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency("assert", ["~> 2.16.5"])
  gem.add_development_dependency("ardb",   ["~> 0.28.3"])

  gem.add_dependency("much-plugin", ["~> 0.2.0"])

end

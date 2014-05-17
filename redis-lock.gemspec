# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redis-lock/version'

Gem::Specification.new do |gem|
  gem.name          = "redis-lock"
  gem.version       = Redis::Lock::VERSION
  gem.authors       = ["Patrick Tulskie"]
  gem.email         = ["patricktulskie@gmail.com"]
  gem.description   = %q{Pessimistic locking for ruby redis}
  gem.summary       = %q{Pessimistic locking for ruby redis}
  gem.homepage      = "https://github.com/PatrickTulskie/redis-lock"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency "redis"
  gem.add_development_dependency "rspec"
end
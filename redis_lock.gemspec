# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "redis_lock/version"

Gem::Specification.new do |s|
  s.name     = %q{redis_lock}
  s.version  = RedisLock::VERSION
  s.email    = %q{patricktulskie@gmail.com}
  s.authors  = ["Patrick Tulskie"]
  s.homepage = %q{http://github.com/PatrickTulskie/redis-lock}

  s.summary     = %q{Adds the ability to utilize client-side pessimistic locking in Redis.}
  s.description = %q{Adds the ability to utilize client-side pessimistic locking in Redis.}

  s.extra_rdoc_files = ["README.md"]
  s.rdoc_options = ["--charset=UTF-8"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake",   "0.8.7"
  s.add_development_dependency "redis",  "~> 2.2.0"
  s.add_development_dependency "rspec",  "~> 2.6.0"
  s.add_development_dependency "mocha",  "~> 0.9.8"
  s.add_development_dependency "bourne", "~> 1.0"
end

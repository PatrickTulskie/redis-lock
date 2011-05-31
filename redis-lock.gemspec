# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name     = %q{redis-lock}
  s.version  = "0.1.0"
  s.email    = %q{patricktulskie@gmail.com}
  s.authors  = ["Patrick Tulskie"]
  s.homepage = %q{http://github.com/PatrickTulskie/redis-lock}

  s.summary = %q{Adds the ability to utilize client-side pessimistic locking in Redis.}
  s.description = <<-DESC
  Adds pessimistic locking capabilities to the redis gem.

  Since these capabilities are utilized client-side, all clients must use this gem and follow the order of lock => make changes => unlock in order to obtain maximum safety when modifying sensitive keys.

  Tested with redis-server 2.0.4 and should work with all versions > 0.091.
  DESC

  s.extra_rdoc_files = ["README.md"]
  s.rdoc_options = ["--charset=UTF-8"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "redis", "~> 2.2.0"

  s.add_development_dependency "rspec", "~> 2.6.0"
  s.add_development_dependency "mocha", "~> 0.9.8"
  s.add_development_dependency "bourne", "~> 1.0"
end

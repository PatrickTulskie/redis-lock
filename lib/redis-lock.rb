require "redis"

class Redis
  autoload :Lock, "redis-lock/lock"

  include Redis::Lock
end

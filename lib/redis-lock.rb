require File.dirname(__FILE__) + '/../lib/redis/lock'

class Redis
  include Redis::Lock
end

class RedisLockException < StandardError; end
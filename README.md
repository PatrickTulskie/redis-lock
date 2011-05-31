redis-lock
==========

Installation
------------

    gem install redis-lock
    require "redis_lock"

Usage
-----

    redis = Redis.new

    RedisLock.new(redis, "my-awesome-lock-key").lock_with_update do
      this_will_only_happen_if_the_lock_is_acquired
    end

`RedisLock` defaults to 10 retries; you can override by setting the number of retries:

    RedisLock.new(redis, "my-awesome-lock-key").retry(5.times).lock_with_update do
      this_will_only_happen_if_the_lock_is_acquired_in_up_to_5_tries
    end

`RedisLock` will raise a `RedisLock::LockNotAcquired` exception if the lock can't be
acquired; you'll want to handle this case in your application.

    begin
      RedisLock.new(redis, "my-awesome-lock-key").lock_with_update do
        # lock was acquired
      end
    rescue RedisLock::LockNotAcquired
      # couldn't acquire lock!
    end

Additionally, `RedisLock` will raise a `RedisLock::UnlockFailure` if the lock could
not be removed. This could happen if the locking key got removed somehow. This
will still execute the code within the lock_with_update call.

    begin
      RedisLock.new(redis, "my-awesome-lock-key").lock_with_update do
        # if the lock was acquired, this will always be run
      end
    rescue RedisLock::UnlockFailure
      # the lock key went away
    end

If you want to lock and unlock manually outside of the context of a block, you
can call lock and unlock explicitly.

    class SomethingAwesome
      before_save :lock_it_up
      after_save  :break_the_lock

      private

      def locker
        @locker ||= RedisLock.new($redis, "my-awesome-lock-key")
      end

      def lock_it_up
        begin
          locker.lock
        rescue RedisLock::LockNotAcquired
          false
        end
      end

      def break_the_lock
        begin
          locker.lock
        rescue RedisLock::UnlockFailure
        end
      end
    end

Additional Notes
----------------

This gem basically implements the algorithm described here: http://redis.io/commands/setnx

Author
------

Patrick Tulskie; http://patricktulskie.com

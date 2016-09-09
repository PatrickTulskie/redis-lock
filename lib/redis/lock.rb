require 'redis'

class Redis
  module Lock

    # Lock a given key for updating
    #
    # Example:
    #
    # $redis = Redis.new
    # lock_for_update('beers_on_the_wall', 20, 1000) do
    #   $redis.decr('beers_on_the_wall')
    # end

    def lock_for_update(key, timeout = 60, max_attempts = 100)
      if self.lock(key, timeout, max_attempts)
        response = nil
        begin
          response = yield if block_given?
        ensure
          self.unlock(key)
        end
        return response
      end
    end

    # Lock a given key.  Optionally takes a timeout and max number of attempts to lock the key before giving up.
    #
    # Example:
    #
    # $redis.lock('beers_on_the_wall', 10, 100)

    def lock(key, timeout = 60, max_attempts = 100, sleep_duration = 1)
      current_lock_key = lock_key(key)
      expiration_value = lock_expiration(timeout)
      attempt_counter = 0
      while attempt_counter < max_attempts
        if self.setnx(current_lock_key, expiration_value)
          return true
        else
          current_lock = self.get(current_lock_key)
          if (current_lock.to_s.split('-').first.to_i) < Time.now.to_i
            compare_value = self.getset(current_lock_key, expiration_value)
            return true if compare_value == current_lock
          end
        end

        yield if block_given?

        attempt_counter += 1
        sleep sleep_duration if attempt_counter < max_attempts
      end

      raise RedisLockException.new("Unable to acquire lock for #{key}.")
    end

    # Unlock a previously locked key if it has not expired and the current process/thread was the one that locked it.
    #
    # Example:
    #
    # $redis.unlock('beers_on_the_wall')

    def unlock(key)
      current_lock_key = lock_key(key)
      lock_value = self.get(current_lock_key)
      return true unless lock_value
      lock_timeout, lock_process, lock_thread = lock_value.split('-')
      if (lock_timeout.to_i > Time.now.to_i) && (lock_process.to_i == Process.pid) && lock_thread.to_i == Thread.current.object_id
        self.del(current_lock_key)
        return true
      else
        return false
      end
    end

    private

    def lock_expiration(timeout)
      "#{Time.now.to_i + timeout + 1}-#{Process.pid}-#{Thread.current.object_id}"
    end

    def lock_key(key)
      "lock:#{key}"
    end

  end
end

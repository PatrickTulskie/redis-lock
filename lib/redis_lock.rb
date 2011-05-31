class RedisLock
  class LockNotAcquired < Exception; end
  class UnlockFailure   < Exception; end

  def initialize(redis, key)
    @key             = key
    @redis           = redis
    @locked          = false
    @retries         = 10
    @failed_attempts = 0
  end

  def key
    "lock:#{@key}"
  end

  def lock
    ensure_attempted_limit_not_exceeded!

    if successfully_locked_key?
      @locked = true
      @failed_attempts = 0
    else
      increment_attempts
      sleep 0.2
      lock
    end
  end

  def lock_for_update
    if lock
      begin
        yield
      ensure
        unlock
      end
    end
  end

  def unlock
    return unless locked?

    if successfully_unlocked_key?
      @locked = false
    else
      raise UnlockFailure, "Unable to unlock key: #{@key}"
    end
  end

  def retry(enumerator)
    @retries = enumerator.to_a.last + 1
    self
  end

  def locked?
    @locked
  end

  private

  def increment_attempts
    @failed_attempts += 1
  end

  def reached_attempted_limit?
    @failed_attempts >= @retries
  end

  def successfully_locked_key?
    @redis.setnx(key, 1)
  end

  def successfully_unlocked_key?
    @redis.del(key) == 1
  end

  def ensure_attempted_limit_not_exceeded!
    if reached_attempted_limit?
      raise LockNotAcquired, "Unable to acquire lock for key: #{@key}"
    end
  end
end

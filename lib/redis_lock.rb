class RedisLock
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
    return false if reached_attempted_limit?

    if successfully_locked_key?
      @locked = true
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
    return false unless locked?

    if successfully_unlocked_key?
      @locked = false
      true
    else
      false
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
end

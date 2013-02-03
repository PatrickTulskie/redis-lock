class RedisLock
  class LockNotAcquired < Exception; end
  class UnlockFailure   < Exception; end

  def initialize(redis, key)
    @redis  = redis
    @key    = key
    @locked = false
    @retry  = Retry.new
  end

  def key
    "lock:#{@key}"
  end

  def lock
    while !successfully_locked_key?
      @retry.run
      ensure_attempted_limit_not_exceeded!
    end

    @retry.reset
    @locked = true
  end

  def unlock
    return unless locked?

    if successfully_unlocked_key?
      @locked = false
    else
      raise UnlockFailure, "Unable to unlock key: #{@key}"
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

  def retry(enumerator)
    if enumerator.is_a?(Numeric)
      @retry.count = enumerator
    else
      @retry.count = enumerator.to_a.last + 1
    end
    self
  end

  def every(seconds)
    @retry.interval = seconds
    self
  end

  def locked?
    @locked
  end

  private

  def successfully_locked_key?
    @redis.setnx(key, 1)
  end

  def successfully_unlocked_key?
    @redis.del(key) == 1
  end

  def ensure_attempted_limit_not_exceeded!
    if @retry.limit?
      raise LockNotAcquired, "Unable to acquire lock for key: #{@key}"
    end
  end

  class Retry
    attr_reader   :attempts
    attr_accessor :count, :interval

    def initialize(count = 10, interval = 0.2)
      @count    = count
      @interval = interval
      @attempts = 0
    end

    def run
      increment
      Kernel.sleep interval
    end

    def limit?
      @attempts >= @count
    end

    def increment
      @attempts += 1
    end

    def reset
      @attempts = 0
    end
  end
end

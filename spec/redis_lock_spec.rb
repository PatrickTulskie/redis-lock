require "spec_helper"
require "redis"

describe RedisLock, "#lock" do
  let(:locking_key) { "redis-lock-locking-key" }
  let(:redis)       { Redis.new }
  subject           { RedisLock.new(redis, locking_key) }

  before { redis.flushdb }

  it "locks when a lock can be acquired" do
    subject.should_not be_locked
    subject.lock
    subject.should be_locked
  end

  it "raises an exception if the lock cannot be acquired" do
    subject.lock
    expect do
      subject.lock
    end.to raise_error(RedisLock::LockNotAcquired,
                       "Unable to acquire lock for key: #{locking_key}")
  end

  it "retries a set number of times" do
    subject.lock

    redis_stub = redis.stubs(:setnx).returns(false)
    3.times { redis_stub = redis_stub.then.returns(false) }

    redis_stub.then.returns(true)

    expect do
      subject.retry(5.times).lock
    end.to_not raise_error(RedisLock::LockNotAcquired)

    redis.should have_received(:setnx).times(5)
    subject.should be_locked
  end
end

describe RedisLock, "#unlock" do
  let(:locking_key) { "redis-lock-locking-key" }
  let(:redis)       { Redis.new }

  let(:unlocked)    { RedisLock.new(redis, locking_key) }
  let(:locked) do
    unlocked.tap do |lock|
      lock.lock
    end
  end

  before { redis.flushdb }

  context "when locked" do
    subject { locked }

    it "knows it is not locked" do
      subject.unlock
      subject.should_not be_locked
    end

    it "raises an exception if it can't unlock correctly" do
      redis.del(subject.key)
      expect { subject.unlock }.to raise_error(RedisLock::UnlockFailure, "Unable to unlock key: #{locking_key}")
    end
  end

  context "when not locked" do
    subject { unlocked }

    it "knows it is not locked" do
      subject.unlock
      subject.should_not be_locked
    end
  end
end

describe RedisLock, "#lock_for_update" do
  let(:locking_key) { "redis-lock-locking-key" }
  let(:redis)       { Redis.new }
  subject           { RedisLock.new(redis, locking_key) }

  before { redis.flushdb }

  context "when a lock can be acquired" do
    it "runs a block" do
      result = "changes within lock"

      subject.lock_for_update do
        result = "changed!"
      end

      result.should == "changed!"
    end

    it "locks the key during execution" do
      subject.lock_for_update do
        subject.should be_locked
      end
    end

    it "unlocks the key after completion" do
      subject.lock_for_update { }
      subject.should_not be_locked
    end

    it "unlocks when the block raises" do
      expect do
        subject.lock_for_update do
          raise RuntimeError, "something went wrong!"
        end
      end.to raise_error(RuntimeError, "something went wrong!")

      subject.should_not be_locked
    end

    it "runs the block but raises if unlocking failed" do
      result = "changes within lock"

      expect do
        subject.lock_for_update do
          redis.del(subject.key)
          result = "changed!"
        end
      end.to raise_error(RedisLock::UnlockFailure)

      result.should == "changed!"
    end
  end

  context "when a lock cannot be acquired" do
    before { subject.lock }

    it "does not run the block" do
      result = "doesn't change within lock"

      expect do
        subject.lock_for_update do
          result = "changed!"
        end
      end.to raise_error(RedisLock::LockNotAcquired)

      result.should == "doesn't change within lock"
    end

    it "remains locked" do
      expect { subject.lock_for_update { } }.to raise_error(RedisLock::LockNotAcquired)

      subject.should be_locked
    end
  end
end

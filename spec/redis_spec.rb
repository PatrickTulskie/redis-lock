require 'spec_helper'

describe Redis, "with locking and unlocking" do
  before { subject.flushdb }

  it "should respond to lock" do
    subject.should respond_to(:lock)
  end

  it "should respond to unlock" do
    subject.should respond_to(:unlock)
  end

  it "should respond to lock_for_update" do
    subject.should respond_to(:lock_for_update)
  end

  it "should lock a key" do
    subject.lock('test_key').should be_true
    subject.get('lock:test_key').should_not be_empty
  end

  it "should unlock a key" do
    subject.lock('test_key').should be_true
    subject.unlock('test_key').should be_true
  end

  it "should raise an exception if unable to acquire lock" do
    subject.lock('test_key', 9000)
    lambda { subject.lock('test_key', 9000, 1) }.should raise_exception("Unable to acquire lock for test_key.")
  end

  it "should execute a block during a lock_for_update transaction" do
    subject.lock_for_update('test_key', 9000) { subject.set('test_key', 'awesome') }
    subject.get('test_key').should == 'awesome'
  end

  it "should unlock at the end of a lock_for_update" do
    subject.lock_for_update('test_key', 9000) { subject.set('test_key', 'awesome') }
    subject.get('lock:test_key').should be_nil
  end
end

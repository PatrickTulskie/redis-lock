require 'spec_helper'
require 'redis-lock'
require 'logger'

describe 'redis' do
  
  before(:all) do
    @redis = Redis.new
  end

  before(:each) do
    @redis.flushdb
  end

  after(:each) do
    @redis.flushdb
  end

  after(:all) do
    @redis.quit
  end
  
  it "should respond to lock" do
    @redis.should respond_to(:lock)
  end
  
  it "should respond to unlock" do
    @redis.should respond_to(:unlock)
  end
  
  it "should respond to lock_for_update" do
    @redis.should respond_to(:lock_for_update)
  end
  
  it "should lock a key" do
    @redis.lock('test_key').should be_true
    @redis.get('lock:test_key').should_not be_empty
  end
  
  it "should unlock a key" do
    @redis.lock('test_key').should be_true
    @redis.unlock('test_key').should be_true
  end
  
  it "should raise an exception if unable to acquire lock" do
    @redis.lock('test_key', 9000)
    lambda { @redis.lock('test_key', 9000, 1) }.should raise_exception("Unable to acquire lock for test_key.")
  end
  
  it "should execute a block during a lock_for_update transaction" do
    @redis.lock_for_update('test_key', 9000) { @redis.set('test_key', 'awesome') }
    @redis.get('test_key').should == 'awesome'
  end
  
  it "should unlock at the end of a lock_for_update" do
    @redis.lock_for_update('test_key', 9000) { @redis.set('test_key', 'awesome') }
    @redis.get('lock:test_key').should be_nil
  end
  
end
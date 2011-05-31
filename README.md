redis-lock
==========

Requires the redis gem.  Including this in your project will give you additional locking abilities on any instance of a redis connection you create.

Installation
------------

    gem install redis-lock

Usage
-----

    require 'redis'
    require 'redis-lock # This will automatically include Lock into the Redis class.

Here's a little example of what you can do with it:

    timeout = 10 # measured in seconds
    max_attempts = 100 # number of times the action will attempt to lock the key before raising an exception

    $redis = Redis.new

    $redis.lock('beers_on_the_wall', timeout, max_attempts)
    # Now no one can acquire a lock on 'beers_on_the_wall'

    $redis.unlock('beers_on_the_wall')
    # Other processes can now acquire a lock on 'beers_on_the_wall'

For convenience, there is also a `lock_with_update` function that accepts a block.  It handles the locking and unlocking for you.

    $redis.lock_for_update('beers_on_the_wall') do
      $redis.multi do
        $redis.set('sing', 'take one down, pass it around.')
        $redis.decr('beers_on_the_wall')
      end
    end

Additional Notes
----------------

This gem basically implements the algorithm described here: http://redis.io/commands/setnx

Author
------

Patrick Tulskie; http://patricktulskie.com

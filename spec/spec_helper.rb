require "rubygems"
require "bundler"

Bundler.require(:development)

require "redis_lock"

RSpec.configure do |config|
  config.mock_with :mocha
end

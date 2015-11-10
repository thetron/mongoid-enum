$: << File.expand_path("../../lib", __FILE__)

require 'mongoid'
require "mongoid/rspec"
require 'mongoid/enum'

ENV['MONGOID_ENV'] = "test"

RSpec.configure do |config|
  config.include Mongoid::Matchers

  config.before(:each) do
    Mongoid.purge!
  end
end

Mongoid.load!(File.expand_path("../support/mongoid.yml", __FILE__), :test)
Mongo::Logger.logger.level = ::Logger::INFO

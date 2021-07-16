# frozen_string_literal: true

$: << File.expand_path('../lib', __dir__)

require 'mongoid'
require 'mongoid/rspec'
require 'mongoid/enum'

ENV['MONGOID_ENV'] = 'test'

RSpec.configure do |config|
  config.include Mongoid::Matchers

  config.before(:each) do
    Mongoid.purge!
  end
end

Mongoid.load!(File.expand_path('support/mongoid.yml', __dir__), :test)
Mongo::Logger.logger.level = ::Logger::INFO

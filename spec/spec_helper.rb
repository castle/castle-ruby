# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'webmock/rspec'
require 'byebug'

require 'coveralls'
Coveralls.wear!

require 'castle'

Castle.configure do |config|
  config.api_secret = 'secret'
  config.api_endpoint = 'https://api.castle.io/v1'
end

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
end

# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'webmock/rspec'
require 'pry'
require 'castle'

Castle.configure do |config|
  config.api_secret = 'secret'
end

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each) do
    Castle.config.api_endpoint = 'https://api.castle.io/v1'
    Castle.config.request_timeout = 30.0
    stub_request(:any, /api.castle.io/)
      .to_return(status: 200, body: '{}', headers: {})
  end
end

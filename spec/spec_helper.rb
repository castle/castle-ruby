# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'webmock/rspec'
require 'byebug'
require 'timecop'

require 'coveralls'
Coveralls.wear!

require 'castle'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each) do
    Castle.instance_variable_set(:@configuration, Castle::Configuration.new)

    Castle.configure do |cfg|
      cfg.api_secret = 'secret'
    end
  end
end

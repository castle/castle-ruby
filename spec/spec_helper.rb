# frozen_string_literal: true

require 'simplecov'
SimpleCov.start { add_filter '/spec/' }

require 'rubygems'
require 'bundler/setup'
require 'ostruct' # no longer autoloaded on Ruby 3.5
require 'rack'
require 'webmock/rspec'
require 'timecop'

require 'castle'

WebMock.disable_net_connect!(allow_localhost: true)

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.before do
    Castle.config.reset
    Castle.configure { |cfg| cfg.api_secret = 'secret' }
  end

  config.disable_monkey_patching!
end

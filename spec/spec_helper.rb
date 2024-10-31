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

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  config.before do
    Castle.config.reset
    Castle.configure { |cfg| cfg.api_secret = 'secret' }
  end

  config.disable_monkey_patching!
end

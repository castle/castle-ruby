require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'webmock/rspec'
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter 'spec'
  add_group 'Models', 'lib/castle-rb/models'
  add_group 'Support', 'lib/castle-rb/support'
end

require 'castle-rb'

Castle.configure do |config|
  config.api_secret = 'secretkey'
end

RSpec.configure do |config|
end

require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'vcr'
require 'webmock/rspec'
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter 'spec'
end

require 'castle'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
end

Castleconfigure do |config|
  config.api_secret = 'secretkey'
end

RSpec.configure do |config|
end

require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'userbin'
require 'vcr'
require 'webmock/rspec'
require 'coveralls'
Coveralls.wear!

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
end

Userbin.configure do |config|
  config.api_secret = 'secretkey'
end

RSpec.configure do |config|
end

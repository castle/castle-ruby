require 'her'
require 'multi_json'
require 'openssl'
require 'net/http'

require "userbin/userbin"
require "userbin/basic_auth"

require "userbin/railtie" if defined?(Rails::Railtie)

api_endpoint = ENV.fetch('USERBIN_API_ENDPOINT') {
  "https://api.userbin.com"
}

@api = Her::API.setup url: api_endpoint do |c|
  c.use Userbin::BasicAuth
  c.use Faraday::Request::UrlEncoded
  c.use Her::Middleware::DefaultParseJSON
  c.use Faraday::Adapter::NetHttp
end

require "userbin/configuration"
require "userbin/events"
require "userbin/current"
require "userbin/session"
require "userbin/authentication"

class Userbin::Error < Exception; end
class Userbin::SecurityError < Userbin::Error; end
class Userbin::ConfigurationError < Userbin::Error; end

module Userbin
  class << self
    def configure(config_hash=nil)
      if config_hash
        config_hash.each do |k,v|
          config.send("#{k}=", v)
        end
      end

      yield(config) if block_given?
    end

    def config
      @configuration ||= Userbin::Configuration.new
    end
  end
end

# frozen_string_literal: true

require 'openssl'
require 'net/http'

require 'castle/version'

require 'castle/configuration'
require 'castle/client'
require 'castle/errors'
require 'castle/system'
require 'castle/header_formatter'
require 'castle/extractors/client_id'
require 'castle/extractors/headers'
require 'castle/extractors/ip'
require 'castle/headers'
require 'castle/response'
require 'castle/request'
require 'castle/api'
require 'castle/cookie_store'

# main sdk module
module Castle
  class << self
    def configure(config_hash = nil)
      (config_hash || {}).each do |config_name, config_value|
        config.send("#{config_name}=", config_value)
      end

      yield(config) if block_given?
    end

    def config
      @configuration ||= Castle::Configuration.new
    end

    def api_secret=(api_secret)
      config.api_secret = api_secret
    end
  end
end

require 'castle/support'

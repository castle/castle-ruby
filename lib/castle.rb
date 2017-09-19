# frozen_string_literal: true

require 'openssl'
require 'net/http'
require 'json'

require 'castle/version'
require 'castle/errors'
require 'castle/command'
require 'castle/utils'
require 'castle/utils/merger'
require 'castle/utils/cloner'
require 'castle/context_merger'
require 'castle/default_context'
require 'castle/commands/identify'
require 'castle/commands/authenticate'
require 'castle/commands/track'
require 'castle/configuration'
require 'castle/failover_auth_response'
require 'castle/client'
require 'castle/header_formatter'
require 'castle/secure_mode'
require 'castle/extractors/client_id'
require 'castle/extractors/headers'
require 'castle/extractors/ip'
require 'castle/response'
require 'castle/request'
require 'castle/api'

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

# frozen_string_literal: true

%w[
  openssl
  net/http
  json
  time
].each(&method(:require))

%w[
  castle/version
  castle/events
  castle/errors
  castle/command
  castle/utils
  castle/utils/merger
  castle/utils/cloner
  castle/utils/timestamp
  castle/validators/present
  castle/validators/not_supported
  castle/context/merger
  castle/context/sanitizer
  castle/context/default
  castle/commands/identify
  castle/commands/authenticate
  castle/commands/track
  castle/commands/review
  castle/commands/impersonate
  castle/configuration
  castle/failover_auth_response
  castle/client
  castle/headers_filter
  castle/headers_formatter
  castle/secure_mode
  castle/extractors/client_id
  castle/extractors/headers
  castle/extractors/ip
  castle/api/response
  castle/api/request
  castle/api/request/build
  castle/review
  castle/api
].each(&method(:require))

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
      @config ||= Castle::Configuration.new
    end

    def api_secret=(api_secret)
      config.api_secret = api_secret
    end
  end
end

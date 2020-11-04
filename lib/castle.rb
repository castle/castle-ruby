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
  castle/utils/deep_symbolize_keys
  castle/utils/clean_invalid_chars
  castle/utils/merge
  castle/utils/clone
  castle/utils/get_timestamp
  castle/validators/present
  castle/validators/not_supported
  castle/context/merge
  castle/context/sanitize
  castle/context/get_default
  castle/context/prepare
  castle/commands/identify
  castle/commands/authenticate
  castle/commands/track
  castle/commands/review
  castle/commands/impersonate
  castle/api/identify
  castle/api/authenticate
  castle/api/track
  castle/api/review
  castle/api/impersonate
  castle/payload/prepare
  castle/configuration
  castle/failover/prepare_response
  castle/client
  castle/headers/filter
  castle/headers/format
  castle/headers/extract
  castle/secure_mode
  castle/client_id/extract
  castle/ip/extract
  castle/core/get_connection
  castle/core/process_response
  castle/core/send_request
  castle/session
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
      Configuration.instance
    end

    def api_secret=(api_secret)
      config.api_secret = api_secret
    end
  end
end

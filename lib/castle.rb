# frozen_string_literal: true

%w[
  openssl
  net/http
  json
  time
].each(&method(:require))

%w[
  castle/version
  castle/verdict
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
  castle/commands/approve_device
  castle/commands/authenticate
  castle/commands/end_impersonation
  castle/commands/get_device
  castle/commands/get_devices_for_user
  castle/commands/identify
  castle/commands/report_device
  castle/commands/review
  castle/commands/start_impersonation
  castle/commands/track
  castle/api/approve_device
  castle/api/authenticate
  castle/api/end_impersonation
  castle/api/get_device
  castle/api/get_devices_for_user
  castle/api/identify
  castle/api/report_device
  castle/api/review
  castle/api/start_impersonation
  castle/api/track
  castle/payload/prepare
  castle/configuration
  castle/logger
  castle/failover/prepare_response
  castle/failover/strategy
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

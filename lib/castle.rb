# frozen_string_literal: true

%w[openssl net/http json time].each(&method(:require))

%w[
  castle/version
  castle/verdict
  castle/errors
  castle/command
  castle/utils/deep_symbolize_keys
  castle/utils/clean_invalid_chars
  castle/utils/merge
  castle/utils/clone
  castle/utils/get_timestamp
  castle/utils/secure_compare
  castle/validators/present
  castle/validators/not_supported
  castle/webhooks/verify
  castle/context/merge
  castle/context/sanitize
  castle/context/get_default
  castle/context/prepare
  castle/commands/approve_device
  castle/commands/authenticate
  castle/commands/end_impersonation
  castle/commands/filter
  castle/commands/get_device
  castle/commands/get_devices_for_user
  castle/commands/log
  castle/commands/report_device
  castle/commands/risk
  castle/commands/start_impersonation
  castle/commands/track
  castle/commands/lists/get_all
  castle/commands/lists/create
  castle/commands/lists/delete
  castle/commands/lists/get
  castle/commands/lists/query
  castle/commands/lists/update
  castle/commands/list_items/archive
  castle/commands/list_items/create
  castle/commands/list_items/count
  castle/commands/list_items/get
  castle/commands/list_items/query
  castle/commands/list_items/unarchive
  castle/commands/list_items/update
  castle/api/approve_device
  castle/api/authenticate
  castle/api/end_impersonation
  castle/api/filter
  castle/api/get_device
  castle/api/get_devices_for_user
  castle/api/log
  castle/api/report_device
  castle/api/risk
  castle/api/start_impersonation
  castle/api/track
  castle/api/lists/get_all
  castle/api/lists/create
  castle/api/lists/delete
  castle/api/lists/get
  castle/api/lists/query
  castle/api/lists/update
  castle/api/list_items/archive
  castle/api/list_items/create
  castle/api/list_items/count
  castle/api/list_items/get
  castle/api/list_items/query
  castle/api/list_items/unarchive
  castle/api/list_items/update
  castle/payload/prepare
  castle/configuration
  castle/singleton_configuration
  castle/logger
  castle/failover/prepare_response
  castle/failover/strategy
  castle/client_actions/lists
  castle/client_actions/list_items
  castle/client
  castle/headers/filter
  castle/headers/format
  castle/headers/extract
  castle/secure_mode
  castle/client_id/extract
  castle/ips/extract
  castle/core/get_connection
  castle/core/process_response
  castle/core/send_request
  castle/core/process_webhook
  castle/session
  castle/api
].each(&method(:require))

# main sdk module
module Castle
  class << self
    def configure(config_hash = nil)
      (config_hash || {}).each { |config_name, config_value| config.send(:"#{config_name}=", config_value) }

      yield(config) if block_given?
    end

    def config
      SingletonConfiguration.instance
    end

    def api_secret=(api_secret)
      config.api_secret = api_secret
    end
  end
end

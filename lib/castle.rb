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
  castle/commands/list/all
  castle/commands/list/create
  castle/commands/list/delete
  castle/commands/list/get
  castle/commands/list/query
  castle/commands/list/update
  castle/commands/list_item/archive
  castle/commands/list_item/create
  castle/commands/list_item/count
  castle/commands/list_item/get
  castle/commands/list_item/query
  castle/commands/list_item/unarchive
  castle/commands/list_item/update
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
  castle/api/list/all
  castle/api/list/create
  castle/api/list/delete
  castle/api/list/get
  castle/api/list/query
  castle/api/list/update
  castle/api/list_item/archive
  castle/api/list_item/create
  castle/api/list_item/count
  castle/api/list_item/get
  castle/api/list_item/query
  castle/api/list_item/unarchive
  castle/api/list_item/update
  castle/payload/prepare
  castle/configuration
  castle/singleton_configuration
  castle/logger
  castle/failover/prepare_response
  castle/failover/strategy
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

# frozen_string_literal: true

module Castle
  module Core
    # this module returns a new configured Net::HTTP object
    module GetConnection
      class << self
        # @param config [Castle::Configuration, Castle::SingletonConfiguration]
        # @return [Net::HTTP]
        def call(config = nil)
          config ||= Castle.config
          http = Net::HTTP.new(config.base_url.host, config.base_url.port)
          # `request_timeout` is in milliseconds for historical reasons; both
          # Net::HTTP timeouts take seconds.
          timeout_seconds = config.request_timeout / 1000.0
          http.open_timeout = timeout_seconds
          http.read_timeout = timeout_seconds

          if config.base_url.scheme == 'https'
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          end

          http
        end
      end
    end
  end
end

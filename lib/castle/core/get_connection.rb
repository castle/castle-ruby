# frozen_string_literal: true

module Castle
  module Core
    # this module returns a new configured Net::HTTP object
    module GetConnection
      HTTPS_SCHEME = 'https'

      class << self
        # @param config [Castle::Configuration, Castle::SingletonConfiguration]
        # @return [Net::HTTP]
        def call(config = nil)
          config ||= Castle.config
          http = Net::HTTP.new(config.base_url.host, config.base_url.port)
          http.read_timeout = config.request_timeout / 1000.0

          if config.base_url.scheme == HTTPS_SCHEME
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          end

          http
        end
      end
    end
  end
end

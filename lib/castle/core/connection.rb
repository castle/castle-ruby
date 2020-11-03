# frozen_string_literal: true

module Castle
  module Core
    # this module returns a new configured Net::HTTP object
    module Connection
      HTTPS_SCHEME = 'https'

      class << self
        def call
          http = Net::HTTP.new(Castle.config.base_url.host, Castle.config.base_url.port)
          http.read_timeout = Castle.config.request_timeout / 1000.0

          if Castle.config.base_url.scheme == HTTPS_SCHEME
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          end

          http
        end
      end
    end
  end
end

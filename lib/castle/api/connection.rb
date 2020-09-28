# frozen_string_literal: true

module Castle
  module API
    module Connection
      HTTPS_SCHEME = 'https'

      class << self
        def call
          http = Net::HTTP.new(Castle.config.url.host, Castle.config.url.port)
          http.read_timeout = Castle.config.request_timeout / 1000.0

          if Castle.config.url.scheme == HTTPS_SCHEME
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          end

          http
        end
      end
    end
  end
end

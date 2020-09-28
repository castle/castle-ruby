# frozen_string_literal: true

module Castle
  module API
    module Connection
      HTTPS_SCHEME = 'https'

      class << self
        def call
          conn_options = {
            read_timeout: Castle.config.request_timeout / 1000.0
          }

          if Castle.config.url.scheme == HTTPS_SCHEME
            conn_options[:use_ssl] = true
            conn_options[:verify_mode] = OpenSSL::SSL::VERIFY_PEER
          end

          Net::HTTP.new(Castle.config.url.host, Castle.config.url.port, conn_options)
        end
      end
    end
  end
end

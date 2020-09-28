# frozen_string_literal: true

module Castle
  module API
    # this class keeps http config object
    # and provides start/finish methods for persistent connection usage
    # when there is a need of sending multiple requests at once
    class Session
      attr_accessor :http

      class << self
        def call
          return unless block_given?

          conn_options = {
            read_timeout: Castle.config.request_timeout / 1000.0
          }

          if Castle.config.port == 443
            conn_options[:use_ssl] = true
            conn_options[:verify_mode] = OpenSSL::SSL::VERIFY_PEER
          end

          Net::HTTP.start(Castle.config.host, Castle.config.port, conn_options) do |http|
            yield(http)
          end
        end
      end
    end
  end
end

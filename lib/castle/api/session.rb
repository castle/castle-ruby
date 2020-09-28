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
          Net::HTTP.start(Castle.config.host, Castle.config.port) do |http|
            http.read_timeout = Castle.config.request_timeout / 1000.0

            if Castle.config.port == 443
              http.use_ssl = true
              http.verify_mode = OpenSSL::SSL::VERIFY_PEER
            end

            yield(http) if block_given?
          end
        end
      end
    end
  end
end

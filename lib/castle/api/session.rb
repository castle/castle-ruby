# frozen_string_literal: true

module Castle
  module API
    # this class keeps http config object
    # and provides start/finish methods for persistent connection usage
    # when there is a need of sending multiple requests at once
    class Session
      attr_accessor :http

      # @return [Net::HTTP]
      def initialize
        reset
      end

      def reset
        @http = Net::HTTP.new(Castle.config.host, Castle.config.port)
        @http.read_timeout = Castle.config.request_timeout / 1000.0

        if Castle.config.port == 443
          @http.use_ssl = true
          @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        end

        @http
      end
    end
  end
end

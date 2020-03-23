# frozen_string_literal: true

require 'singleton'

module Castle
  module API
    # this class keeps http session for reuse
    class SessionSharer
      include Singleton

      attr_accessor :session

      def initialize
        setup
      end

      def setup
        self.session = Net::HTTP.new(Castle.config.host, Castle.config.port)
        session.read_timeout = Castle.config.request_timeout / 1000.0

        if Castle.config.port == 443
          session.use_ssl = true
          session.verify_mode = OpenSSL::SSL::VERIFY_PEER
        end

        session
      end

      def reset
        self.session = nil
      end

      class << self
        def get
          instance.session
        end
      end
    end
  end
end

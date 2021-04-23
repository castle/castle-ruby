# frozen_string_literal: true

require 'openssl'

module Castle
  module SecureMode
    class << self
      # @param user_id [String]
      # @param config [Castle::Configuration, Castle::SingletonConfiguration, nil]
      def signature(user_id, config = nil)
        config ||= Castle.config
        OpenSSL::HMAC.hexdigest('sha256', config.api_secret, user_id.to_s)
      end
    end
  end
end

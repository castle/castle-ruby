# frozen_string_literal: true

require 'openssl'

module Castle
  module SecureMode
    class << self
      def signature(user_id, config: Castle.config)
        OpenSSL::HMAC.hexdigest('sha256', config.api_secret, user_id.to_s)
      end
    end
  end
end

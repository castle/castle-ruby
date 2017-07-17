# frozen_string_literal: true
require 'openssl'

module Castle
  module SecureMode
    def self.signature(user_id)
      OpenSSL::HMAC.hexdigest('sha256', Castle.config.api_secret, user_id.to_s)
    end
  end
end

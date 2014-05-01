require 'jwt'

module Userbin
  class JWT
    def initialize(jwt)
      begin
        raise Userbin::SecurityError, 'Empty JWT' unless jwt
        @payload = ::JWT.decode(jwt, Userbin.config.api_secret, true) do |header|
          @created_at = Time.at(header['iat']).utc
          @expires_at = Time.at(header['exp']).utc
          Userbin.config.api_secret # used by the 'key finder' in the JWT gem
        end
      rescue ::JWT::DecodeError => e
        raise Userbin::SecurityError.new(e)
      end
    end

    def expired?
      Time.now.utc > @expires_at
    end

    def to_json
      @payload
    end

    def app_id
      @payload['app']
    end
  end
end

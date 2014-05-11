require 'jwt'

module Userbin
  class JWT
    attr_reader :header
    attr_reader :payload

    def initialize(jwt)
      begin
        raise Userbin::SecurityError, 'Empty JWT' unless jwt
        @payload = ::JWT.decode(jwt, Userbin.config.api_secret, true) do |header|
          @header = header.with_indifferent_access
          Userbin.config.api_secret # used by the 'key finder' in the JWT gem
        end.with_indifferent_access
      rescue ::JWT::DecodeError => e
        raise Userbin::SecurityError.new(e)
      end
    end

    def expired?
      Time.now.utc > Time.at(@header['exp']).utc
    end

    def to_json
      @payload
    end

    def to_token
      ::JWT.encode(@payload, Userbin.config.api_secret, "HS256", @header)
    end

    def app_id
      @header['aud']
    end

    def merge!(payload = {})
      @payload.merge!(payload)
    end
  end
end

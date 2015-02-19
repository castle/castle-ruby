require 'jwt'

module Castle
  class JWT
    attr_accessor :header, :payload

    def initialize(jwt)
      begin
        raise Castle::SecurityError, 'Empty JWT' unless jwt
        @payload = ::JWT.decode(jwt, Castle.config.api_secret, true) do |header|
          @header = header.with_indifferent_access
          Castle.config.api_secret # used by the 'key finder' in the JWT gem
        end.with_indifferent_access
      rescue ::JWT::DecodeError => e
        raise Castle::SecurityError.new(e)
      end
    end

    def expired?
      Time.now.utc > Time.at(@header['exp']).utc
    end

    def merge!(payload = {})
      @payload.merge!(payload)
    end

    def to_json
      @payload
    end

    def to_token
      ::JWT.encode(@payload, Castle.config.api_secret, "HS256", @header)
    end

  end
end

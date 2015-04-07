require 'jwt'

module Castle
  class JWT
    attr_accessor :header, :payload

    def initialize(jwt)
      begin
        raise Castle::SecurityError, 'Empty JWT' unless jwt
        @payload, @header = ::JWT.decode(jwt, Castle.config.api_secret, true)
        @payload = @payload.with_indifferent_access
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

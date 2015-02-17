require 'jwt'

module Castle
  class SessionToken
    def initialize(token)
      if token
        @jwt = Castle::JWT.new(token)
      end
    end

    def to_s
      @jwt.to_token
    end

    def expired?
      @jwt.expired?
    end

    def device_trusted?
      @jwt.payload['tru'] == 1
    end

    def has_default_pairing?
      @jwt.payload['dpr'] > 0
    end

    def mfa_enabled?
      @jwt.payload['mfa'] == 1
    end

    def mfa_in_progress?
      @jwt.payload['chg'] == 1
    end

    def mfa_required?
      @jwt.payload['vfy'] > 0
    end
  end
end

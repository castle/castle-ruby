module Userbin
  class Client

    attr_accessor :request_context

    def initialize(request, opts = {})
      # Save a reference in the per-request store so that the request
      # middleware in request.rb can access it
      RequestStore.store[:userbin] = self

      # By default the session token is persisted in the Rack store, which may
      # in turn point to any source. But this option gives you an option to
      # use any store, such as Redis or Memcached to store your Userbin tokens.
      if opts[:session_store]
        @session_store = opts[:session_store]
      else
        @session_store = Userbin::SessionStore::Rack.new(request.session)
      end

      @request_context = {
        ip: request.ip,
        user_agent: request.user_agent
      }
    end

    def authorize!(user_id, user_attrs = {})
      # The user identifier is used in API paths so it needs to be cleaned
      user_id = URI.encode(user_id.to_s)

      @session_store.user_id = user_id

      if !session_token
        session = Userbin::Session.post(
          "users/#{user_id}/sessions", user: user_attrs)
        self.session_token = session.token
      else
        if Userbin::JWT.new(session_token).expired?
          Userbin::Monitoring.heartbeat
        end
      end
    end

    def session_token=(value)
      if value && value != @session_store.read
        @session_store.write(value)
      elsif !value
        @session_store.destroy
      end
    end

    def session_token
      @session_store.read
    end

    def logout
      return unless session_token

      begin
        Userbin::Session.destroy_existing('current')
      rescue Userbin::Error
        # Silently discard logout errors, typically Not Found
      end

      self.session_token = nil
    end

    def two_factor_authenticate!
      return unless session_token

      jwt = Userbin::JWT.new(session_token)

      if jwt.header['vfy'] == 1
        challenge = Userbin::Challenge.post("users/current/challenges")

        # Save payload in Userbin session for easy access when verifying
        jwt = Userbin::JWT.new(session_token)
        jwt.payload = { challenge_id: challenge.id }
        self.session_token = jwt.to_token

        case jwt.header['mfa']
        when 1 then :authenticator
        when 2 then :sms
        when 3 then :call
        end
      end
    end

    def two_factor_verify(response)
      return unless session_token

      jwt = Userbin::JWT.new(session_token)

      return unless jwt.payload['challenge_id']

      challenge = Userbin::Challenge.new(jwt.payload['challenge_id'])
      challenge.verify(response: response)

      # session token may have changed during challenge verification
      jwt = Userbin::JWT.new(session_token)
      jwt.payload = {}
      self.session_token = jwt.to_token
    end

    def security_settings_url
      return '' unless session_token
      return "https://security.userbin.com/?session_token=#{session_token}"
    end

  end
end

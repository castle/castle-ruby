module Userbin
  class << self

    def authenticate(session_token, user_id, opts = {})
      session = Userbin::Session.new(token: session_token)

      user_data = opts.fetch(:properties, {})

      if session.token
        if session.expired?
          session = Userbin.with_context(opts[:context]) do
            session.refresh(user: user_data)
          end
        end
      else
        session = Userbin.with_context(opts[:context]) do
          Userbin::Session.post(
            "users/#{URI.encode(user_id.to_s)}/sessions", user: user_data)
        end
      end

      session_token = session.token

      # By encoding the context to the JWT payload, we avoid having to
      # fetch the context for subsequent Userbin calls during the
      # current request
      jwt = Userbin::JWT.new(session_token)
      jwt.merge!(context: opts[:context])
      jwt.to_token
    end

    def deauthenticate(session_token)
      return unless session_token

      # Extract context from authenticated session token
      jwt = Userbin::JWT.new(session_token)
      context = jwt.payload['context']

      Userbin.with_context(context) do
        Userbin::Session.destroy_existing(session_token)
      end
    end

    def two_factor_authenticate!(session_token)
      return unless session_token

      challenge = Userbin::JWT.new(session_token).payload['challenge']

      if challenge
        case challenge['type']
        when 'otp_authenticator' then :authenticator
        when 'otp_sms' then :sms
        end
      end
    end

    def verify_code(session_token, response)
      return unless session_token

      # Extract context from authenticated session token
      jwt = Userbin::JWT.new(session_token)
      context = jwt.payload['context']

      session = Userbin.with_context(context) do
        Userbin::Session.new(id: session_token).verify(response: response)
      end

      session.token
    end

    def security_page_url(session_token)
      return '' unless session_token
      begin
        app_id = Userbin::JWT.new(session_token).app_id
        "https://security.userbin.com/?session_token=#{session_token}"
      rescue Userbin::Error
        ''
      end
    end

  end
end

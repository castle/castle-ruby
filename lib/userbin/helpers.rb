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
            "/api/v1/users/#{user_id}/sessions", user: user_data)
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
      context = jwt.to_json['context']

      Userbin.with_context(context) do
        Userbin::Session.destroy_existing(session_token)
      end
    end

  end
end

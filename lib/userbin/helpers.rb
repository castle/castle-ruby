module Userbin
  class << self

    def authenticate(opts = {})
      session = Userbin::Session.new(id: opts[:current])

      # Restructure user data to fit API
      user_data = opts.fetch(:properties, {})
      user_data.merge!(local_id: opts[:user_id]) if opts[:user_id]

      if session.id
        if session.expired?
          session = Userbin.with_context(opts[:context]) do
            session.refresh(user: user_data)
          end
        end
      else
        session = Userbin.with_context(opts[:context]) do
          Userbin::Session.create(user: user_data)
        end
      end

      token = session.id

      # By encoding the context to the JWT payload, we avoid having to
      # fetch the context for subsequent Userbin calls during the
      # current request
      jwt = Userbin::JWT.new(token)
      jwt.merge!(context: opts[:context])
      jwt.to_token
    end

    def deauthenticate(token)
      return unless token
      Userbin.with_context(warden.env) do
        Userbin::Session.destroy_existing(token)
      end
    end

  end
end

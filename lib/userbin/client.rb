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

    def session_token=(value)
      if value && value != @session_store.read
        @session_store.write(value)
      elsif !value
        @session_store.destroy
      end
    end

    def session_token
      token = @session_store.read
      Userbin::SessionToken.new(token) if token
    end

    def identify(user_id)
      # The user identifier is used in API paths so it needs to be cleaned
      user_id = URI.encode(user_id.to_s)

      @session_store.user_id = user_id
    end

    def login(user_id, user_attrs = {})
      # Clear the session token if any
      self.session_token = nil

      identify(user_id)

      session = Userbin::Session.post(
        "users/#{@session_store.user_id}/sessions", user: user_attrs)

      # Set the session token for use in all subsequent requests
      self.session_token = session.token
    end

    def authorize
      return unless session_token

      if session_token.expired?
        Userbin::Monitoring.heartbeat
      end
    end

    # This method ends the current monitoring session. It should be called
    # whenever the user logs out from your system.
    #
    def logout
      return unless session_token

      # Destroy the current session specified in the session token
      begin
        Userbin::Session.destroy_existing('current')
      rescue Userbin::Error # ignored
      end

      # Clear the session token
      self.session_token = nil
    end

    # This method creates a two-factor challenge for the current user, if the
    # user has enabled a device for authentication.
    #
    # If there already exists a challenge on the current session, it will be
    # returned. Otherwise a new will be created.
    #
    def two_factor_authenticate!
      return unless session_token

      if session_token.needs_challenge?
        Userbin::Challenge.post("users/current/challenges")
        return two_factor_method
      end
    end

    # Once a two factor challenge has been created using
    # two_factor_authenticate!, the response code from the user is verified
    # using this method.
    #
    def two_factor_verify(response)
      # Need to have an active challenge to verify it
      return unless session_token && session_token.has_challenge?

      challenge = Userbin::Challenge.new('current')
      challenge.verify(response: response)
    end

    def security_settings_url
      raise Userbin::Error unless session_token
      return "https://security.userbin.com/?session_token=#{session_token}"
    end

     # If a two-factor authentication process has been started, this method will
     # return the method which is used to perform the authentication. Eg.
     # :authenticator or :sms
     #
    def two_factor_method
      return unless session_token
      return session_token.challenge_type
    end

    def authorized?
      !!session_token
    end

    def two_factor_in_progress?
      return false unless session_token
      session_token.has_challenge?
    end

    def two_factor_enabled?
      session_token ? session_token.mfa_enabled? : false
    end

    def two_factor_required?
      session_token ? session_token.needs_challenge? : false
    end

    def events
      Userbin::User.new('current').events
    end

    def sessions
      Userbin::User.new('current').sessions
    end

    def pairings
      Userbin::User.new('current').pairings
    end

    def channels
      Userbin::User.new('current').channels
    end

    def recovery_codes
      Userbin::User.new('current').recovery_codes
    end

    def enable_mfa
      Userbin::User.new('current').enable_mfa
    end

    def disable_mfa
      Userbin::User.new('current').disable_mfa
    end

  end
end

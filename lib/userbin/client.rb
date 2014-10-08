module Userbin
  class Client

    attr_accessor :request_context

    def self.install_proxy_methods(*names)
      names.each do |name|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{name}(*args)
            Userbin::User.new('current').#{name}(*args)
          end
        RUBY
      end
    end

    install_proxy_methods :challenges, :events, :sessions, :pairings,
      :recovery_codes, :generate_recovery_codes, :enable_mfa, :disable_mfa

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

    def authorize
      return unless session_token

      if session_token.expired?
        Userbin::Monitoring.heartbeat
      end
    end

    def authorized?
      !!session_token
    end

    def authorize!
      unless session_token
        raise Userbin::UserUnauthorizedError,
          'Need to call login before authorize'
      end

      authorize

      if mfa_in_progress?
        logout
        raise Userbin::UserUnauthorizedError,
            'Logged out due to being unverified'
      end

      raise Userbin::ChallengeRequiredError if mfa_required?
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

    # This method ends the current monitoring session. It should be called
    # whenever the user logs out from your system.
    #
    def logout
      return unless session_token

      # Destroy the current session specified in the session token
      begin
        sessions.destroy('current')
      rescue Userbin::Error # ignored
      end

      # Clear the session token
      self.session_token = nil
    end

    def mfa_enabled?
      session_token ? session_token.mfa_enabled? : false
    end

    def mfa_in_progress?
      session_token ? session_token.has_challenge? : false
    end

    def mfa_required?
      session_token ? session_token.needs_challenge? : false
    end

  end
end

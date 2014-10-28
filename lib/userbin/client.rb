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
      :backup_codes, :generate_backup_codes, :trusted_devices,
      :enable_mfa, :disable_mfa

    def initialize(request, cookies, opts = {})
      # Save a reference in the per-request store so that the request
      # middleware in request.rb can access it
      RequestStore.store[:userbin] = self

      # By default the session token is persisted in the Rack store, which may
      # in turn point to any source. This option give you an option to
      # use any store, such as Redis or Memcached to store your Userbin tokens.
      if opts[:session_store]
        @session_store = opts[:session_store]
      else
        @session_store = Userbin::SessionStore::Rack.new(request.session)
      end

      @trusted_token_store = Userbin::TrustedTokenStore::Rack.new(cookies)

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

    def trusted_device_token=(value)
      if value && value != @trusted_token_store.read
        @trusted_token_store.write(value)
      elsif !value
        @trusted_token_store.destroy
      end
    end

    def trusted_device_token
      @trusted_token_store.read
    end

    def identify(user_id)
      # The user identifier is used in API paths so it needs to be cleaned
      user_id = URI.encode(user_id.to_s)

      @session_store.user_id = user_id
      @trusted_token_store.user_id = user_id
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

      if mfa_required? && !device_trusted?
        raise Userbin::ChallengeRequiredError
      end
    end

    def login(user_id, user_attrs = {})
      # Clear the session token if any
      self.session_token = nil

      identify(user_id)

      user = Userbin::User.new(@session_store.user_id)
      session = user.sessions.create(
        user: user_attrs, trusted_device_token: self.trusted_device_token)

      # Set the session token for use in all subsequent requests
      self.session_token = session.token
    end

    def trust_device(attrs = {})
      trusted_device = trusted_devices.create(attrs)

      # Set the session token for use in all subsequent requests
      self.trusted_device_token = trusted_device.token
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

    def device_trusted?
      session_token ? session_token.device_trusted? : false
    end

    def mfa_in_progress?
      session_token ? session_token.has_challenge? : false
    end

    def mfa_required?
      session_token ? session_token.needs_challenge? : false
    end

    def has_default_pairing?
      session_token ? session_token.has_default_pairing? : false
    end
  end
end

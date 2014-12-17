module Userbin
  class Client

    attr_accessor :request_context

    def self.install_proxy_methods(*names)
      names.each do |name|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{name}(*args)
            Userbin::User.new('$current').#{name}(*args)
          end
        RUBY
      end
    end

    install_proxy_methods :challenges, :events, :sessions, :pairings,
      :backup_codes, :generate_backup_codes, :trusted_devices,
      :enable_mfa!, :disable_mfa!

    def initialize(request, response, opts = {})
      # Save a reference in the per-request store so that the request
      # middleware in request.rb can access it
      RequestStore.store[:userbin] = self

      if response.class.name == 'ActionDispatch::Cookies::CookieJar'
        cookies = Userbin::CookieStore::Rack.new(response)
      else
        cookies = Userbin::CookieStore::Base.new(request, response)
      end

      @store = Userbin::TokenStore.new(cookies)

      @request_context = {
        ip: request.ip,
        user_agent: request.user_agent,
        cookie_id: cookies['__cid']
      }
    end

    def session_token
      @store.session_token
    end

    def session_token=(session_token)
      @store.session_token = session_token
    end

    def authorize!
      unless @store.session_token
        raise Userbin::UserUnauthorizedError,
          'Need to call login before authorize'
      end

      if @store.session_token.expired?
        Userbin::Monitoring.heartbeat
      end

      if mfa_in_progress?
        logout
        raise Userbin::UserUnauthorizedError,
            'Logged out due to being unverified'
      end

      if mfa_required? && !device_trusted?
        raise Userbin::ChallengeRequiredError
      end
    end

    def authorized?
      !!@store.session_token
    end

    def login(user_id, user_attrs = {})
      # Clear the session token if any
      @store.session_token = nil

      user = Userbin::User.new(user_id.to_s)
      session = user.sessions.create(
        user: user_attrs, trusted_device_token: @store.trusted_device_token)

      # Set the session token for use in all subsequent requests
      @store.session_token = session.token

      session
    end

    def logout
      return unless @store.session_token

      # Destroy the current session specified in the session token
      begin
        sessions.destroy('$current')
      rescue Userbin::ApiError # ignored
      end

      # Clear the session token
      @store.session_token = nil
    end

    def trust_device(attrs = {})
      unless @store.session_token
        raise Userbin::UserUnauthorizedError,
          'Need to call login before trusting device'
      end
      trusted_device = trusted_devices.create(attrs)

      # Set the session token for use in all subsequent requests
      @store.trusted_device_token = trusted_device.token
    end

    def mfa_enabled?
      @store.session_token ? @store.session_token.mfa_enabled? : false
    end

    def device_trusted?
      @store.session_token ? @store.session_token.device_trusted? : false
    end

    def mfa_in_progress?
      @store.session_token ? @store.session_token.mfa_in_progress? : false
    end

    def mfa_required?
      @store.session_token ? @store.session_token.mfa_required? : false
    end

    def has_default_pairing?
      @store.session_token ? @store.session_token.has_default_pairing? : false
    end

    def track(opts = {})
      Userbin::Event.post('/v1/events', opts)
    end
  end
end

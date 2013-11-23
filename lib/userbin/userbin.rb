module Userbin
  def self.authenticate_events!(request, now = Time.now)
    signature, data =
      request.params.values_at('signature', 'data')

    valid_signature?(signature, data)

    [signature, data]
  end

  # Provide either a Rack::Request or a Hash containing :signature and :data.
  #
  def self.authenticate!(request, now = Time.now)
    signature, data =
      request.cookies.values_at('_ubs', '_ubd')

    if signature && data && valid_signature?(signature, data)

      current = Userbin::Session.new(MultiJson.decode(data))

      if now > Time.at(current.expires_at / 1000)
        signature, data = refresh_session(current.id)
      end
    end

    tmp = MultiJson.decode(data) if data

    self.current = Userbin::Session.new(tmp)

    [signature, data]
  end

  def self.refresh_session(session_id)
    api_endpoint = ENV["USERBIN_API_ENDPOINT"] || 'https://api.userbin.com'
    uri = URI("#{api_endpoint}/sessions/#{session_id}/refresh")
    uri.user = config.app_id
    uri.password = config.api_secret
    net = Net::HTTP.post_form(uri, {})
    [net['X-Userbin-Signature'], net.body]
  end

  def self.current
    Thread.current[:userbin]
  end

  def self.current=(value)
    Thread.current[:userbin] = value
  end

  def self.authenticated?
    current.authenticated? rescue false
  end

  def self.user_logged_in?
    authenticated?
  end

  def self.user_signed_in?
    authenticated?
  end

  def self._current_user
    current.user if current
  end

  def self.current_user
    if _current_user
      if Userbin.config.find_user
        u = Userbin.config.find_user.call(_current_user.id)
        return u if u
        if Userbin.config.create_user

          # Fetch a full profile from the API. This way we can get more
          # sensitive details than those stored in the cookie. It also checks
          # that the user still exists in Userbin.
          profile = User.find(_current_user.id)

          u = Userbin.config.create_user.call(profile)
          return u if u

          _current_user
        else
          raise ConfigurationError, "You need to implement create_user"
        end
      else
        _current_user
      end
    end
  end

  def self.user
    current_user
  end

  private

  # Checks signature against secret and returns boolean
  #
  def self.valid_signature?(signature, data)
    digest = OpenSSL::Digest::SHA256.new
    valid = signature == OpenSSL::HMAC.hexdigest(digest, config.api_secret, data)
    raise SecurityError, "Invalid signature" unless valid
    valid
  end
end

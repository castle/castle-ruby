require 'jwt'

module Userbin
  def self.decode_jwt(jwt)
    JWT.decode(jwt, Userbin.config.api_secret)
  end

  def self.authenticate!(request)
    jwt = request.cookies['_ubt']
    return unless jwt

    decoded = Userbin.decode_jwt(jwt)

    if Time.now > Time.at(decoded['expires_at'] / 1000)
      jwt = refresh_session(decoded['id'])
      return unless jwt

      decoded = Userbin.decode_jwt(jwt)

      if Time.now > Time.at(decoded['expires_at'] / 1000)
        raise Userbin::SecurityError
      end
    end

    self.current = Userbin::Session.new(decoded)

    return jwt
  end

  def self.refresh_session(session_id)
    api_endpoint = ENV["USERBIN_API_ENDPOINT"] || 'https://api.userbin.com'
    uri = URI("#{api_endpoint}/sessions/#{session_id}/refresh.jwt")
    uri.user = config.app_id
    uri.password = config.api_secret
    net = Net::HTTP.post_form(uri, {})
    net.body
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

  def self.logged_in?
    authenticated?
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

  def self.current_profile
    _current_user
  end

  def self.current_user
    if _current_user
      if Userbin.config.find_user
        u = Userbin.config.find_user.call(_current_user.id)
        if u
          u
        else
          if Userbin.config.create_user

            # Fetch a full profile from the API. This way we can get more
            # sensitive details than those stored in the cookie. It also checks
            # that the user still exists in Userbin.
            profile = User.find(_current_user.id)

            u = Userbin.config.create_user.call(profile)
            if u
              u
            else
              _current_user
            end
          else
            raise ConfigurationError, "You need to implement create_user"
          end
        end
      else
        _current_user
      end
    end
  end

  def self.user
    current_user
  end
end

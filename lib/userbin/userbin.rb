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

      if current.authenticated?
        # FIXME: NoMethodError (undefined method `/' for nil:NilClass):
        if now > Time.at(current.expires_at / 1000)
          signature, data = refresh_session(current.user.id)
        end
      end
    end

    tmp = MultiJson.decode(data) if data

    self.current = Userbin::Session.new(tmp)

    [signature, data]
  end

  def self.refresh_session(user_id)
    api_endpoint = ENV["USERBIN_API_ENDPOINT"] || 'https://api.userbin.com'
    uri = URI("#{api_endpoint}/users/#{user_id}/sessions")
    net = Net::HTTP.post_form(uri, {})
    uri.user = config.app_id
    uri.password = config.api_secret
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

  def self.current_user
    current.user if current
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

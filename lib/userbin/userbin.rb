module Userbin

  Callback = Struct.new(:pattern, :block) do; end

  class << self
    attr_accessor :app_id, :api_secret, :restricted_path
  end

  def self.authenticate_events!(request, now = Time.now)
    signature, data =
      request.params.values_at('userbin_signature', 'userbin_data')

    valid_signature?(signature, data)

    [signature, data]
  end

  # Provide either a Rack::Request or a Hash containing :signature and :data.
  #
  def self.authenticate!(request, now = Time.now)
    signature, data =
      request.cookies.values_at('userbin_signature', 'userbin_data')

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
    api_endpoint = ENV["USERBIN_API_ENDPOINT"] || 'https://userbin.com/api/v0'
    uri = URI("#{api_endpoint}/users/#{user_id}/sessions")
    uri.user = app_id
    uri.password = api_secret
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

  def self.current_user
    current.user if current
  end

  def self.user
    current_user
  end

  # Event handling
  #
  class << self
    def on(*names, &block)
      pattern = Regexp.union(names.empty? ? TYPE_LIST.to_a : names)
      callbacks.each do |callback|
        if pattern == callback.pattern
          callbacks.delete(callback)
          callbacks << Userbin::Callback.new(pattern, block)
          return
        end
      end
      callbacks << Userbin::Callback.new(pattern, block)
    end

    def trigger(raw_event)
      event = Userbin::Event.new(raw_event)
      callbacks.each do |callback|
        if event.type =~ callback.pattern
          object = case event['type']
          when /^user\./
            Userbin::User.new(event.object)
          else
            event.object
          end
          model = event.instance_exec object, &callback.block

          if event.type =~ /user\.created/ && model.respond_to?(:id)
            object.update_local_id(model.id)
          end
        end
      end
    end

    private

    def callbacks
      @callbacks ||= []
    end
  end

  private

  # Checks signature against secret and returns boolean
  #
  def self.valid_signature?(signature, data)
    digest = OpenSSL::Digest::SHA256.new
    valid = signature == OpenSSL::HMAC.hexdigest(digest, api_secret, data)
    raise SecurityError, "Invalid signature" unless valid
    valid
  end
end

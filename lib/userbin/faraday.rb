module Userbin
  class BasicAuth < Faraday::Middleware
    def initialize(app, api_secret)
      super(app)
      @api_secret = api_secret
    end

    def call(env)
      value = Base64.encode64("#{@api_secret || Userbin.config.api_secret}:")
      value.gsub!("\n", '')
      env[:request_headers]["Authorization"] = "Basic #{value}"
      @app.call(env)
    end
  end

  class ContextHeaders < Faraday::Middleware
    def call(env)
      userbin_headers = RequestStore.store.fetch(:userbin_headers, [])
      userbin_headers.each do |key, value|
        header =
          "X-Userbin-#{key.to_s.gsub('_', '-').gsub(/\w+/) {|m| m.capitalize}}"
        env[:request_headers][header] = value
      end
      @app.call(env)
    end
  end

  class JSONParser < Her::Middleware::DefaultParseJSON
    # This method is triggered when the response has been received. It modifies
    # the value of `env[:body]`.
    #
    # @param [Hash] env The response environment
    # @private
    def on_complete(env)
      env[:body] = '{}' if [204, 405].include?(env[:status])
      env[:body] = case env[:status]
      when 403
        raise Userbin::ForbiddenError.new(
          MultiJson.decode(env[:body])['message'])
      when 419
        raise Userbin::UserUnauthorizedError.new(
          MultiJson.decode(env[:body])['message'])
      when 423
        payload = MultiJson.decode(env[:body])
        challenge = Userbin::Challenge.new(payload['params'])
        raise Userbin::ChallengeException.new(challenge), payload['message']
      when 400..599
        raise Userbin::Error.new(MultiJson.decode(env[:body])['message'])
      else
        parse(env[:body])
      end
    end
  end
end

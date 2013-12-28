module Userbin
  class BasicAuth < Faraday::Middleware
    def call(env)
      value = Base64.encode64([Userbin.config.app_id, Userbin.config.api_secret].join(':'))
      value.gsub!("\n", '')
      env[:request_headers]["Authorization"] = "Basic #{value}"
      @app.call(env)
    end
  end

  class VerifySignature < Faraday::Response::Middleware
    def call(env)
      @app.call(env).on_complete do
        Userbin.decode_jwt(env[:body])
      end
    end
  end

  class ParseSignedJSON < Faraday::Response::Middleware
    def on_complete(env)
      json = MultiJson.load(env[:body], symbolize_keys: true)
      signature = env[:response_headers]['x-userbin-signature']
      json[:signature] = signature if signature
      env[:body] = {
        data: json,
        errors: [],
        metadata: {}
      }
    end
  end
end

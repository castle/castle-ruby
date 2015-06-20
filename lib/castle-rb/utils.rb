# TODO: scope Castle::Utils

module Castle
  class << self
    def setup_api(api_secret = nil)
      api_endpoint = ENV.fetch('CASTLE_API_ENDPOINT') {
        "https://api.castle.io/v1"
      }

      Her::API.setup url: api_endpoint do |c|
        c.use Castle::Request::Middleware::BasicAuth, api_secret
        c.use Castle::Request::Middleware::RequestErrorHandler
        c.use Castle::Request::Middleware::EnvironmentHeaders
        c.use Castle::Request::Middleware::ContextHeaders
        c.use FaradayMiddleware::EncodeJson
        c.use Castle::Request::Middleware::JSONParser
        c.use Faraday::Adapter::NetHttp
      end
    end
  end
end

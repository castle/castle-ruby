# TODO: scope Userbin::Utils

module Userbin
  class << self
    def setup_api(api_secret = nil)
      api_endpoint = ENV.fetch('USERBIN_API_ENDPOINT') {
        "https://secure.userbin.com/v1"
      }

      Her::API.setup url: api_endpoint do |c|
        c.use Userbin::Request::Middleware::BasicAuth, api_secret
        c.use Userbin::Request::Middleware::RequestErrorHandler
        c.use Userbin::Request::Middleware::EnvironmentHeaders
        c.use Userbin::Request::Middleware::ContextHeaders
        c.use Userbin::Request::Middleware::SessionToken
        c.use FaradayMiddleware::EncodeJson
        c.use Userbin::Request::Middleware::JSONParser
        c.use Faraday::Adapter::NetHttp
      end
    end
  end
end

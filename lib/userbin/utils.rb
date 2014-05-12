# TODO: scope Userbin::Utils

module Userbin
  class << self
    def setup_api(api_secret = nil)
      api_endpoint = ENV.fetch('USERBIN_API_ENDPOINT') {
        "https://secure.userbin.com/v1"
      }

      Her::API.setup url: api_endpoint do |c|
        c.use Userbin::Request::Middleware::BasicAuth, api_secret
        c.use Userbin::Request::Middleware::EnvironmentHeaders
        c.use Userbin::Request::Middleware::ContextHeaders
        c.use FaradayMiddleware::EncodeJson
        c.use Userbin::Request::Middleware::JSONParser
        c.use Faraday::Adapter::NetHttp
      end
    end

    def with_context(opts, &block)
      return block.call unless opts
      RequestStore.store[:userbin_headers] = {}
      RequestStore.store[:userbin_headers][:ip] = opts[:ip] if opts[:ip]
      RequestStore.store[:userbin_headers][:user_agent] = opts[:user_agent] if opts[:user_agent]
      block.call
    end
  end
end

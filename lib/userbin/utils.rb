module Userbin
  def self.setup_api(api_secret = nil)
    api_endpoint = ENV.fetch('USERBIN_API_ENDPOINT') {
      "https://api.userbin.com/v1"
    }

    Her::API.setup url: api_endpoint do |c|
      c.use Userbin::BasicAuth, api_secret
      c.use Userbin::ContextHeaders
      c.use FaradayMiddleware::EncodeJson
      c.use Userbin::JSONParser
      c.use Faraday::Adapter::NetHttp
    end
  end

  def self.with_context(request, &block)
    RequestStore.store[:userbin_headers] = {
      ip: request.ip,
      user_agent: request.user_agent
    }
    block.call
  end
end

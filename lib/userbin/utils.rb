module Userbin
  def self.setup_api(api_secret = nil)
    api_endpoint = ENV.fetch('USERBIN_API_ENDPOINT') {
      "https://api.userbin.com/v1"
    }

    Her::API.setup url: api_endpoint do |c|
      c.use Userbin::BasicAuth, api_secret
      #c.use Userbin::ContextHeaders
      c.use FaradayMiddleware::EncodeJson
      c.use Userbin::JSONParser
      c.use Faraday::Adapter::NetHttp
    end
  end
end

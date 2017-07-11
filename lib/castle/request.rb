# frozen_string_literal: true

module Castle
  # generate api request
  class Request
    def initialize(headers)
      @config = Castle.config
      @headers = headers
    end

    def build(endpoint, args, method)
      http_method = method.to_s.capitalize
      request = Net::HTTP.const_get(http_method).new(
        "#{@config.api_endpoint.path}/#{endpoint}", @headers
      )
      request.basic_auth('', @config.api_secret)
      request.body = args.to_json unless http_method == 'Get'
      request
    end
  end
end

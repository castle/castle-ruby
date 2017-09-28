# frozen_string_literal: true

module Castle
  # generate api request
  class Request
    def initialize(headers = {})
      @config = Castle.config
      @headers = headers
    end

    def build_query(endpoint)
      request = Net::HTTP::Get.new(build_url(endpoint), @headers)
      add_basic_auth(request)
      request
    end

    def build(endpoint, args, method)
      request = Net::HTTP.const_get(method.to_s.capitalize).new(build_url(endpoint), @headers)
      request.body = ::Castle::Utils.replace_invalid_characters(args).to_json
      add_basic_auth(request)
      request
    end

    private

    def build_url(endpoint)
      "/#{@config.url_prefix}/#{endpoint}"
    end

    def add_basic_auth(request)
      request.basic_auth('', @config.api_secret)
    end
  end
end

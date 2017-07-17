# frozen_string_literal: true

module Castle
  # this class is responsible for making requests to api
  class API
    def initialize(cookie_id, ip, headers)
      @config = Castle.config
      @config_api_endpoint = @config.api_endpoint
      @http = prepare_http
      @headers = Castle::Headers.new.prepare(cookie_id, ip, headers)
    end

    def request_query(endpoint)
      request = Castle::Request.new(@headers).build_query(endpoint)
      perform_request(request)
    end

    def request(endpoint, args, method = :post)
      request = Castle::Request.new(@headers).build(endpoint, args, method)
      perform_request(request)
    end

    private

    def prepare_http
      http = Net::HTTP.new(
        @config_api_endpoint.host,
        @config_api_endpoint.port
      )
      http.read_timeout = @config.request_timeout / 1000.0
      prepare_http_for_ssl(http) if @config_api_endpoint.scheme == 'https'
      http
    end

    def prepare_http_for_ssl(http)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    def perform_request(req)
      Castle::Response.new(@http.request(req)).parse
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
           Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
           Net::ProtocolError
      raise Castle::RequestError, 'Castle API connection error'
    end
  end
end

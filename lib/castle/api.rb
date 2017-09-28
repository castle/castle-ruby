# frozen_string_literal: true

module Castle
  # this class is responsible for making requests to api
  class API
    def initialize(headers = {})
      @config = Castle.config
      @http = prepare_http
      @headers = headers.merge('Content-Type' => 'application/json')
    end

    def request_query(endpoint)
      request = Castle::Request.new(@headers).build_query(endpoint)
      perform_request(request)
    end

    def request(command)
      request = Castle::Request.new(@headers).build(
        command.path,
        command.data,
        command.method
      )
      perform_request(request)
    end

    private

    def prepare_http
      http = Net::HTTP.new(@config.host, @config.port)
      http.read_timeout = @config.request_timeout / 1000.0
      prepare_http_for_ssl(http) if @config.port == 443
      http
    end

    def prepare_http_for_ssl(http)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    def perform_request(request)
      raise Castle::ConfigurationError, 'configuration is not valid' unless @config.valid?
      begin
        Castle::Response.new(@http.request(request)).parse
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
             Net::ProtocolError
        raise Castle::RequestError, 'Castle API connection error'
      end
    end
  end
end

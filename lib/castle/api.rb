# frozen_string_literal: true

module Castle
  class API
    attr_accessor :http, :headers

    def initialize(cookie_id, ip, headers)
      prepare_http
      prepare_headers(cookie_id, ip, headers)
    end

    def prepare_http
      @http = Net::HTTP.new(Castle.config.api_endpoint.host,
                            Castle.config.api_endpoint.port)

      @http.read_timeout = Castle.config.request_timeout

      if Castle.config.api_endpoint.scheme == 'https'
        @http.use_ssl = true
        @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end
      @http
    end

    def prepare_headers(cookie_id, ip, headers)
      @headers = {
        'Content-Type' => 'application/json',
        'X-Castle-Cookie-Id' => cookie_id,
        'X-Castle-Ip' => ip,
        'X-Castle-Headers' => headers,
        'X-Castle-Client-User-Agent' => JSON.generate(client_user_agent),
        'X-Castle-Source' => Castle.config.source_header,
        'User-Agent' => "Castle/v1 RubyBindings/#{Castle::VERSION}"
      }
      @headers.delete_if { |_k, v| v.nil? }
    end

    def request(endpoint, args, method: :post)
      req = prepare_request(endpoint, args, method)
      response = perform_request!(req)
      verify_response_code!(response)

      parse_response!(response)
    end

    def prepare_request(endpoint, args, method)
      http_method = method.to_s.capitalize
      req = Net::HTTP.const_get(http_method).new(
        "#{Castle.config.api_endpoint.path}/#{endpoint}", @headers
      )
      req.basic_auth('', Castle.config.api_secret)
      req.body = args.to_json unless http_method == 'Get'
      req
    end

    def parse_response!(response)
      return {} if response.body.nil? || response.body.empty?

      begin
        JSON.parse(response.body, symbolize_names: true)
      rescue JSON::ParserError
        raise Castle::ApiError, 'Invalid response from Castle API'
      end
    end

    def perform_request!(req)
      @http.request(req)
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
           Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
           Net::ProtocolError
      raise Castle::RequestError, 'Castle API connection error'
    end

    def verify_response_code!(response)
      response_code = response.code.to_i

      case response_code
      when 200..299
        return
      when *Castle::RESPONSE_ERRORS.keys
        raise Castle::RESPONSE_ERRORS[response_code], response[:message]
      else
        raise Castle::ApiError, response[:message]
      end
    end

    def client_user_agent
      @uname ||= fetch_uname
      version = "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})"

      {
        bindings_version: Castle::VERSION,
        lang: 'ruby',
        lang_version: version,
        platform: RUBY_PLATFORM,
        publisher: 'castle',
        uname: @uname
      }
    end

    def fetch_uname
      `uname -a 2>/dev/null`.strip if RUBY_PLATFORM =~ /linux|darwin/i
    rescue Errno::ENOMEM # couldn't create subprocess
      'uname lookup failed'
    end
  end
end

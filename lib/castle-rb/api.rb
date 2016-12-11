module Castle
  class API
    attr_accessor :http, :headers

    def initialize(cookie_id, ip, headers)
      @http = Net::HTTP.new(Castle.config.api_endpoint.host,
                            Castle.config.api_endpoint.port)

      @http.read_timeout = Castle.config.request_timeout

      if Castle.config.api_endpoint.scheme == 'https'
        @http.use_ssl = true
        @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end

      @headers = {
        "Content-Type" => "application/json",
        "X-Castle-Cookie-Id" => cookie_id,
        "X-Castle-Ip" => ip,
        "X-Castle-Headers" => headers,
        "X-Castle-Client-User-Agent" => JSON.generate(client_user_agent),
        "X-Castle-Source" => Castle.config.source_header,
        "User-Agent" => "Castle/v1 RubyBindings/#{Castle::VERSION}"
      }

      @headers.delete_if { |k, v| v.nil? }
    end

    def request(endpoint, args)
      req = Net::HTTP::Post.new(
        "#{Castle.config.api_endpoint.path}/#{endpoint}", @headers)
      req.basic_auth("", Castle.config.api_secret)
      req.body = args.to_json

      begin
        response = @http.request(req)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
             Net::ProtocolError, Net::ReadTimeout => e
        raise Castle::RequestError, 'Castle API connection error'
      end

      case response.code.to_i
      when 200..299
        # OK
      when 400
        raise Castle::BadRequestError, response[:message]
      when 401
        raise Castle::UnauthorizedError, response[:message]
      when 403
        raise Castle::ForbiddenError, response[:message]
      when 404
        raise Castle::NotFoundError, response[:message]
      when 419
        raise Castle::UserUnauthorizedError, response[:message]
      when 422
        raise Castle::InvalidParametersError, response[:message]
      else
        raise Castle::ApiError, response[:message]
      end

      if response.body.nil? || response.body.empty?
        {}
      else
        begin
          JSON.parse(response.body, :symbolize_names => true)
        rescue JSON::ParserError
          raise Castle::ApiError, 'Invalid response from Castle API'
        end
      end
    end

    def client_user_agent
      @uname ||= get_uname
      lang_version = "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})"

      {
        :bindings_version => Castle::VERSION,
        :lang => 'ruby',
        :lang_version => lang_version,
        :platform => RUBY_PLATFORM,
        :publisher => 'castle',
        :uname => @uname
      }
    end

    def get_uname
      `uname -a 2>/dev/null`.strip if RUBY_PLATFORM =~ /linux|darwin/i
    rescue Errno::ENOMEM # couldn't create subprocess
      "uname lookup failed"
    end
  end
end

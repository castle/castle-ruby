module Userbin
  module Request

    def self.client_user_agent
      @uname ||= get_uname
      lang_version = "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})"

      {
        :bindings_version => Userbin::VERSION,
        :lang => 'ruby',
        :lang_version => lang_version,
        :platform => RUBY_PLATFORM,
        :publisher => 'userbin',
        :uname => @uname
      }
    end

    def self.get_uname
      `uname -a 2>/dev/null`.strip if RUBY_PLATFORM =~ /linux|darwin/i
    rescue Errno::ENOMEM # couldn't create subprocess
      "uname lookup failed"
    end

    #
    # Faraday middleware
    #
    module Middleware
      # Sets credentials dynamically, allowing them to change between requests.
      #
      class BasicAuth < Faraday::Middleware
        def initialize(app, api_secret)
          super(app)
          @api_secret = api_secret
        end

        def call(env)
          value = Base64.encode64(":#{@api_secret || Userbin.config.api_secret}")
          value.gsub!("\n", '')
          env[:request_headers]["Authorization"] = "Basic #{value}"
          @app.call(env)
        end
      end

      # Handle request errors
      #
      class RequestErrorHandler < Faraday::Middleware
        def call(env)
          env.request.timeout = Userbin.config.request_timeout
          begin
            @app.call(env)
          rescue Faraday::ConnectionFailed
            raise Userbin::RequestError, 'Could not connect to Userbin API'
          rescue Faraday::TimeoutError
            raise Userbin::RequestError, 'Userbin API timed out'
          end
        end
      end

      # Adds details about current environment
      #
      class EnvironmentHeaders < Faraday::Middleware
        def call(env)
          begin
            env[:request_headers]["X-Userbin-Client-User-Agent"] =
              MultiJson.encode(Userbin::Request.client_user_agent)
          rescue # ignored
          end

          env[:request_headers]["User-Agent"] =
            "Userbin/v1 RubyBindings/#{Userbin::VERSION}"

          @app.call(env)
        end
      end

      # Sends the active session token in a header, and extracts the returned
      # session token and sets it locally.
      #
      class SessionToken < Faraday::Middleware
        def call(env)
          userbin = RequestStore.store[:userbin]
          return @app.call(env) unless userbin

          # get the session token from our local store
          if userbin.session_token
            env[:request_headers]['X-Userbin-Session-Token'] =
              userbin.session_token.to_s
          end

          # call the API
          response = @app.call(env)

          # update the local store with the updated session token
          token = response.env.response_headers['x-userbin-session-token']
          userbin.session_token = token if token

          response
        end
      end

      # Adds request context like IP address and user agent to any request.
      #
      class ContextHeaders < Faraday::Middleware
        def call(env)
          userbin = RequestStore.store[:userbin]
          return @app.call(env) unless userbin

          userbin.request_context.each do |key, value|
            header =
              "X-Userbin-#{key.to_s.gsub('_', '-').gsub(/\w+/) {|m| m.capitalize}}"
            env[:request_headers][header] = value
          end
          @app.call(env)
        end
      end

      class JSONParser < Faraday::Response::Middleware
        def on_complete(env)
          response = if env[:body].nil? || env[:body].empty?
            {}
          else
            begin
              MultiJson.load(env[:body], :symbolize_keys => true)
            rescue MultiJson::LoadError
              raise Userbin::ApiError, 'Invalid response from Userbin API'
            end
          end

          case env[:status]
          when 200..299
            # OK
          when 400
            raise Userbin::BadRequestError, response[:message]
          when 401
            raise Userbin::UnauthorizedError, response[:message]
          when 403
            raise Userbin::ForbiddenError, response[:message]
          when 404
            raise Userbin::NotFoundError, response[:message]
          when 419
            raise Userbin::UserUnauthorizedError, response[:message]
          when 422
            raise Userbin::InvalidParametersError, response[:message]
          else
            raise Userbin::ApiError, response[:message]
          end

          env[:body] = {
            data: response,
            metadata: [],
            errors: {}
          }
        end
      end

    end

  end
end

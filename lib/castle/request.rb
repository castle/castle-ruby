module Castle
  module Request

    def self.client_user_agent
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
          value = Base64.encode64(":#{@api_secret || Castle.config.api_secret}")
          value.delete!("\n")
          env[:request_headers]["Authorization"] = "Basic #{value}"
          @app.call(env)
        end
      end

      # Handle request errors
      #
      class RequestErrorHandler < Faraday::Middleware
        def call(env)
          env.request.timeout = Castle.config.request_timeout
          begin
            @app.call(env)
          rescue Faraday::ConnectionFailed
            raise Castle::RequestError, 'Could not connect to Castle API'
          rescue Faraday::TimeoutError
            raise Castle::RequestError, 'Castle API timed out'
          end
        end
      end

      # Adds details about current environment
      #
      class EnvironmentHeaders < Faraday::Middleware
        def call(env)
          begin
            env[:request_headers]["X-Castle-Client-User-Agent"] =
              MultiJson.encode(Castle::Request.client_user_agent)
          rescue # ignored
          end

          env[:request_headers]["User-Agent"] =
            "Castle/v1 RubyBindings/#{Castle::VERSION}"

          @app.call(env)
        end
      end

      # Sends the active session token in a header, and extracts the returned
      # session token and sets it locally.
      #
      class SessionToken < Faraday::Middleware
        def call(env)
          castle = RequestStore.store[:castle]
          return @app.call(env) unless castle

          # get the session token from our local store
          if castle.session_token
            env[:request_headers]['X-Castle-Session-Token'] =
              castle.session_token.to_s
          end

          # call the API
          response = @app.call(env)

          # update the local store with the updated session token
          token = response.env.response_headers['X-Castle-set-session-token']
          castle.session_token = token if token

          response
        end
      end

      # Adds request context like IP address and user agent to any request.
      #
      class ContextHeaders < Faraday::Middleware
        def call(env)
          castle = RequestStore.store[:castle]
          return @app.call(env) unless castle

          castle.request_context.each do |key, value|
            if value
             header =
              "X-Castle-#{key.to_s.gsub('_', '-').gsub(/\w+/) {|m| m.capitalize}}"
              env[:request_headers][header] = value
            end
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
              raise Castle::ApiError, 'Invalid response from Castle API'
            end
          end

          case env[:status]
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
            # session token is invalid so clear it
            RequestStore.store[:castle].session_token = nil

            raise Castle::UserUnauthorizedError, response[:message]
          when 422
            raise Castle::InvalidParametersError, response[:message]
          else
            raise Castle::ApiError, response[:message]
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

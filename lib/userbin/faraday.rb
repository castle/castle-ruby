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
    rescue Errno::ENOMEM => ex # couldn't create subprocess
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
          value = Base64.encode64("#{@api_secret || Userbin.config.api_secret}:")
          value.gsub!("\n", '')
          env[:request_headers]["Authorization"] = "Basic #{value}"
          @app.call(env)
        end
      end

      # Adds details about current environment
      #
      class EnvironmentHeaders < Faraday::Middleware
        def call(env)
          begin
            env[:request_headers]["X-Userbin-Client-User-Agent"] =
              MultiJson.encode(Userbin::Request.client_user_agent)
          rescue => e
            binding.pry
            #env[:request_headers]["X-Userbin-Client-Raw-User-Agent"] =
           #   user_agent.inspect, error: "#{e} (#{e.class})"
          end

          env[:request_headers]["User-Agent"] =
            "Userbin/v1 RubyBindings/#{Userbin::VERSION}"

          @app.call(env)
        end
      end

      # Adds request context like IP address and user agent to any request.
      #
      class ContextHeaders < Faraday::Middleware
        def call(env)
          userbin_headers = RequestStore.store.fetch(:userbin_headers, [])
          userbin_headers.each do |key, value|
            header =
              "X-Userbin-#{key.to_s.gsub('_', '-').gsub(/\w+/) {|m| m.capitalize}}"
            env[:request_headers][header] = value
          end
          @app.call(env)
        end
      end

      class JSONParser < Her::Middleware::DefaultParseJSON
        # This method is triggered when the response has been received. It modifies
        # the value of `env[:body]`.
        #
        # @param [Hash] env The response environment
        # @private
        def on_complete(env)
          env[:body] = '{}' if [204, 405].include?(env[:status])
          env[:body] = case env[:status]
          when 403
            raise Userbin::ForbiddenError.new(
              MultiJson.decode(env[:body])['message'])
          when 419
            raise Userbin::UserUnauthorizedError.new(
              MultiJson.decode(env[:body])['message'])
          when 400..599
            raise Userbin::Error.new(MultiJson.decode(env[:body])['message'])
          else
            parse(env[:body])
          end
        end
      end
    end

  end
end

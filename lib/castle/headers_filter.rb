# frozen_string_literal: true

module Castle
  # used for preparing valuable headers list
  class HeadersFilter
    # headers filter
    # HTTP_ - this is how Rack prefixes incoming HTTP headers
    # CONTENT_LENGTH - for responses without Content-Length or Transfer-Encoding header
    # REMOTE_ADDR - ip address header returned by web server
    VALUABLE_HEADERS = /^
      HTTP(?:_|-).*|
      CONTENT(?:_|-)LENGTH|
      REMOTE(?:_|-)ADDR
    $/xi.freeze

    private_constant :VALUABLE_HEADERS

    # @param request [Rack::Request]
    def initialize(request)
      @request_env = request.env
      @formatter = HeadersFormatter
    end

    # Serialize HTTP headers
    # @return [Hash]
    def call
      @request_env.keys.each_with_object({}) do |header_name, acc|
        next unless header_name.match(VALUABLE_HEADERS)

        formatted_name = @formatter.call(header_name)
        acc[formatted_name] = @request_env[header_name]
      end
    end
  end
end

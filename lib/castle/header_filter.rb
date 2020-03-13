# frozen_string_literal: true

module Castle
  # used for preparing valuable headers list
  class HeaderFilter
    # headers filter
    VALUABLE_HEADERS = /^(HTTP_.*|CONTENT_LENGTH|REMOTE_ADDR)$/.freeze

    private_constant :VALUABLE_HEADERS

    # @param request [Rack::Request]
    def initialize(request)
      @request_env = request.env
      @formatter = HeaderFormatter.new
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

# frozen_string_literal: true

module Castle
  module Extractors
    # used for extraction of cookies and headers from the request
    class Headers
      # Headers that we will never scrub, even if they land on the configuration blacklist.
      ALWAYS_WHITELISTED = %w[User-Agent].freeze

      # Headers that will always be scrubbed, even if whitelisted.
      ALWAYS_BLACKLISTED = %w[Cookie Authorization].freeze

      # Valubable headers prefixed with HTTP or listed
      VALUABLE_HEADERS = /^(HTTP_.*|CONTENT_LENGTH|REMOTE_ADDR)$/

      private_constant :ALWAYS_WHITELISTED, :ALWAYS_BLACKLISTED, :VALUABLE_HEADERS

      # @param request [Rack::Request]
      def initialize(request)
        @request_env = request.env
        @formatter = HeaderFormatter.new
        @no_whitelist = Castle.config.whitelisted.empty?
      end

      # Serialize HTTP headers
      # @return [Hash]
      def call
        @request_env.keys.each_with_object({}) do |header_name, acc|
          next unless header_name.match(VALUABLE_HEADERS)

          formatted_header_name = @formatter.call(header_name)
          value = @request_env[header_name]

          acc[formatted_header_name] = header_value(formatted_header_name, value)
        end
      end

      private

      # scrub header value
      # @param header [String]
      # @param value [String]
      # @return [TrueClass | FalseClass | String]
      def header_value(header_name, value)
         return true if ALWAYS_BLACKLISTED.include?(header_name)
         return value if ALWAYS_WHITELISTED.include?(header_name)
         return true if Castle.config.blacklisted.include?(header_name)
         return value if @no_whitelist || Castle.config.whitelisted.include?(header_name)

         true
      end
    end
  end
end

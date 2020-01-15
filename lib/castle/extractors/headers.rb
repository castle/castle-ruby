# frozen_string_literal: true

module Castle
  module Extractors
    # used for extraction of cookies and headers from the request
    class Headers
      # Headers that we will never scrub, even if they land on the configuration blacklist.
      ALWAYS_INCLUDED_HEADERS = %w[User-Agent]

      # Headers that will always be scrubbed, even if whitelisted.
      ALWAYS_SCRUBBED_HEADERS = %w[Cookie Authorization]

      CONTENT_LENGTH = 'CONTENT_LENGTH'

      HTTP_HEADER_PREFIX = 'HTTP_'

      private_constant :ALWAYS_INCLUDED_HEADERS, :ALWAYS_SCRUBBED_HEADERS,
                       :CONTENT_LENGTH, :HTTP_HEADER_PREFIX

      # @param request [Rack::Request]
      def initialize(request)
        @request_env = request.env
        @formatter = HeaderFormatter.new
      end

      # Serialize HTTP headers
      # @return [Hash]
      def call
        @request_env.keys.each_with_object({}) do |env_header, acc|
          next unless env_header.start_with?(HTTP_HEADER_PREFIX) || env_header == CONTENT_LENGTH

          header = @formatter.call(env_header)

          if ALWAYS_SCRUBBED_HEADERS.include?(header)
            acc[header] = true
          elsif ALWAYS_INCLUDED_HEADERS.include?(header)
            acc[header] = @request_env[env_header]
          elsif Castle.config.blacklisted.include?(header)
            acc[header] = true
          elsif Castle.config.whitelisted.empty? || Castle.config.whitelisted.include?(header)
            acc[header] = @request_env[env_header]
          else
            acc[header] = true
          end
        end
      end
    end
  end
end

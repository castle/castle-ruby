# frozen_string_literal: true

module Castle
  module Extractors
    # used for extraction of cookies and headers from the request
    class Headers
      def initialize(request)
        @request = request
        @request_env = @request.env
        @disabled_headers = ['Cookie']
      end

      # Serialize HTTP headers
      def extract
        headers = http_headers.each_with_object({}) do |header, acc|
          name = format_header_name(header)
          unless @disabled_headers.include?(name)
            acc[name] = @request_env[header]
          end
        end

        JSON.generate(headers)
      end

      private

      def format_header_name(header)
        header.gsub(/^HTTP_/, '').split('_').map(&:capitalize).join('-')
      end

      def http_headers
        @request_env.keys.grep(/^HTTP_/)
      end
    end
  end
end

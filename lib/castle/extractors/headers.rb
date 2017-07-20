# frozen_string_literal: true

module Castle
  module Extractors
    # used for extraction of cookies and headers from the request
    class Headers
      def initialize(request)
        @request = request
        @request_env = @request.env
        @formatter = HeaderFormatter.new
      end

      # Serialize HTTP headers
      def call
        headers = @request_env.keys.each_with_object({}) do |header, acc|
          name = @formatter.call(header)
          next unless Castle.config.whitelisted.include?(name)
          next if Castle.config.blacklisted.include?(name)
          acc[name] = @request_env[header]
        end

        JSON.generate(headers)
      end
    end
  end
end

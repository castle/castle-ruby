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
        @request_env.keys.each_with_object({}) do |header, acc|
          name = @formatter.call(header)

          if Castle.config.whitelisted.include?(name) && !Castle.config.blacklisted.include?(name)
            acc[name] = @request_env[header]
          else
            # When a header is not whitelisted or blacklisted, we're not suppose to send
            # it's value but we should send it's name to indicate it's presence
            acc[name] = true
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Castle
  module Context
    class Default
      def initialize(request, cookies = nil)
        @pre_headers = HeaderFilter.new(request).call
        @cookies = cookies || request.cookies
        @request = request
      end

      def call
        {
          client_id: client_id,
          active: true,
          origin: 'web',
          headers: headers,
          ip: ip,
          library: {
            name: 'castle-rb',
            version: Castle::VERSION
          }
        }.tap do |result|
          result[:locale] = locale if locale
          result[:user_agent] = user_agent if user_agent
        end
      end

      private

      def locale
        @pre_headers['Accept-Language']
      end

      def user_agent
        @pre_headers['User-Agent']
      end

      def ip
        Extractors::IP.new(@pre_headers).call
      end

      def client_id
        Extractors::ClientId.new(@pre_headers, @cookies).call
      end

      def headers
        Extractors::Headers.new(@pre_headers).call
      end
    end
  end
end

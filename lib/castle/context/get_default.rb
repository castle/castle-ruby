# frozen_string_literal: true

module Castle
  module Context
    class GetDefault
      def initialize(request, cookies = nil)
        @pre_headers = Castle::Headers::Filter.new(request).call
        @cookies = cookies || request.cookies
        @request = request
      end

      def call
        {
          client_id: client_id,
          active: true,
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

      # @return [String]
      def locale
        @pre_headers['Accept-Language']
      end

      # @return [String]
      def user_agent
        @pre_headers['User-Agent']
      end

      # @return [String]
      def ip
        Extractors::IP.new(@pre_headers).call
      end

      # @return [String]
      def client_id
        Extractors::ClientId.new(@pre_headers, @cookies).call
      end

      # formatted and filtered headers
      # @return [Hash]
      def headers
        Castle::Headers::Extract.new(@pre_headers).call
      end
    end
  end
end

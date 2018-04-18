# frozen_string_literal: true

module Castle
  module Context
    class Default
      def initialize(request, cookies = nil)
        @client_id = Extractors::ClientId.new(request, cookies || request.cookies).call
        @headers = Extractors::Headers.new(request).call
        @request_ip = Extractors::IP.new(request).call
      end

      def call
        defaults.merge!(additional_defaults)
      end

      private

      def defaults
        {
          client_id: @client_id,
          active: true,
          origin: 'web',
          headers: @headers,
          ip: @request_ip,
          library: {
            name: 'castle-rb',
            version: Castle::VERSION
          }
        }
      end

      def additional_defaults
        {}.tap do |result|
          result[:locale] = @headers['Accept-Language'] if @headers['Accept-Language']
          result[:user_agent] = @headers['User-Agent'] if @headers['User-Agent']
        end
      end
    end
  end
end

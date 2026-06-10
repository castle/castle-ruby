# frozen_string_literal: true

module Castle
  module Context
    class GetDefault
      def initialize(request)
        @pre_headers = Castle::Headers::Filter.new(request).call
      end

      def call
        { headers: headers, ip: ip, library: { name: 'castle-rb', version: Castle::VERSION } }
      end

      private

      # @return [String]
      def ip
        Castle::IPs::Extract.new(@pre_headers).call
      end

      # formatted and filtered headers
      # @return [Hash]
      def headers
        Castle::Headers::Extract.new(@pre_headers).call
      end
    end
  end
end

# frozen_string_literal: true

module Castle
  module Options
    # fetches default context from the request options
    class GetDefault
      def initialize(request, cookies = nil)
        @pre_headers = Castle::Headers::Filter.new(request).call
        @cookies = cookies || request.cookies
        @request = request
      end

      def call
        { fingerprint: fingerprint, headers: headers, ip: ip }
      end

      private

      # @return [String]
      def ip
        Castle::IPs::Extract.new(@pre_headers).call
      end

      # @return [String]
      def fingerprint
        Castle::Fingerprint::Extract.new(@pre_headers, @cookies).call
      end

      # formatted and filtered headers
      # @return [Hash]
      def headers
        Castle::Headers::Extract.new(@pre_headers).call
      end
    end
  end
end

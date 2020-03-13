# frozen_string_literal: true

module Castle
  module Extractors
    # used for extraction of cookies and headers from the request
    class ClientId
      def initialize(headers, cookies)
        @headers = headers
        @cookies = cookies || {}
      end

      def call
        @headers['X-Castle-Client-Id'] || @cookies['__cid'] || ''
      end
    end
  end
end

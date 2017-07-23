# frozen_string_literal: true

module Castle
  module Extractors
    # used for extraction of cookies and headers from the request
    class ClientId
      def initialize(request, cookies)
        @request = request
        @cookies = cookies || {}
      end

      def call(name)
        @cookies[name] ||
          @request.env.fetch('HTTP_X_CASTLE_CLIENT_ID', '')
      end
    end
  end
end

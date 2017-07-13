# frozen_string_literal: true

module Castle
  module Extractors
    # used for extraction of cookies and headers from the request
    class Cookie
      def initialize(request)
        @request = request
      end

      def extract(response, name)
        extract_cookie(response)[name] || ''
      end

      private

      # Extract the cookie set by the Castle Javascript
      def extract_cookie(response)
        if response.class.name == 'ActionDispatch::Cookies::CookieJar'
          Castle::CookieStore::Rack.new(response)
        else
          Castle::CookieStore::Base.new(@request, response)
        end
      end
    end
  end
end

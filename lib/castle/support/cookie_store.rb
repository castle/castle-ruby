# frozen_string_literal: true

module Castle
  module CookieStore
    class Base
      EXPIRATION_TIME = 20 * 365 * 24 * 60 * 60 # cookie expiration time 20y

      def initialize(request, response)
        @request = request
        @response = response
      end

      def [](key)
        @request.cookies[key]
      end

      def []=(key, value)
        @request.cookies[key] = value
        if value
          @response.set_cookie(key,
                               value: value,
                               expires: Time.now + self.class::EXPIRATION_TIME,
                               path: '/')
        else
          @response.delete_cookie(key)
        end
      end
    end

    class Rack
      def initialize(cookies)
        @cookies = cookies
      end

      def [](key)
        @cookies[key]
      end

      def []=(key, value)
        if value
          @cookies[key] = {
            value: value,
            expires: Time.now + self.class::EXPIRATION_TIME,
            path: '/'
          }
        else
          @cookies.delete(key)
        end
      end
    end
  end
end

module Userbin
  class CookieStore
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
        @response.set_cookie(key, value: value,
                                  expires: Time.now + (365 * 24 * 60 * 60),
                                  path: '/')
      else
        @response.delete_cookie(key)
      end
    end
  end
end

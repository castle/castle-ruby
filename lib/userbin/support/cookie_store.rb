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
      @response.set_cookie key, value
    end
  end
end

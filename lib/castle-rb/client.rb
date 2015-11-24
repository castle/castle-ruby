module Castle
  class Client

    attr_accessor :request_context

    def initialize(request, response, opts = {})
      # Save a reference in the per-request store so that the request
      # middleware in request.rb can access it
      RequestStore.store[:castle] = self

      @request_context = {
        ip: request.ip,
        user_agent: request.user_agent,
        cookie_id: extract_cookies(request, response)['__cid'] || '',
        headers: header_string(request)
      }
    end

    def identify(user_id, opts = {})
      Castle::User.save_existing(user_id, opts)
    end

    def track(opts = {})
      Castle::Event.create(opts)
    end

    def verify(opts = {})
      Castle::Verification.create(opts)
    end

    def approve(opts = {})
      Castle::Verification.new('$current').approve
    end

    private

    def extract_cookies(request, response)
      # Extract the cookie set by the Castle Javascript
      if response.class.name == 'ActionDispatch::Cookies::CookieJar'
        Castle::CookieStore::Rack.new(response)
      else
        Castle::CookieStore::Base.new(request, response)
      end
    end

    # Serialize HTTP headers
    def header_string(request)
      scrub_headers = ['Cookie']

      headers = request.env.keys.grep(/^HTTP_/).map do |header|
        name = header.gsub(/^HTTP_/, '').split('_').map(&:capitalize).join('-')
        unless scrub_headers.include?(name)
          { name => request.env[header] }
        end
      end.compact.inject(:merge)

      MultiJson.encode(headers)
    end
  end
end

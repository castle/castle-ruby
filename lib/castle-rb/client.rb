module Castle
  class Client

    attr_accessor :request_context, :do_not_track, :http, :headers

    def initialize(request, response, opts = {})
      # Save a reference in the per-request store so that the request
      # middleware in request.rb can access it
      RequestStore.store[:castle] = self

      cookie_id = extract_cookies(request, response)['__cid'] || ''
      ip = request.ip
      headers = header_string(request)

      @http = Net::HTTP.new "api.castle.io", 443
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      @headers = {
        "Content-Type" => "application/json",
        "X-Castle-Cookie-Id" => cookie_id,
        "X-Castle-Ip" => ip,
        "X-Castle-Headers" => headers
      }

      @request_context = {
        ip: ip,
        cookie_id: cookie_id,
        headers: headers
      }
    end

    def identify(user_id, opts = {})
      return if @do_not_track
      Castle::User.save_existing(user_id, opts)
    end

    def track(opts = {})
      return if @do_not_track
      Castle::Event.create(opts)
    end

    def do_not_track!
      @do_not_track = true
    end

    def track!
      @do_not_track = false
    end

    def authenticate(args)
      request('authenticate', args)
    end

    def track(args)
      request('track', args)
    end

    def request(endpoint, args)
      req = Net::HTTP::Post.new("/v1/#{endpoint}", @headers)
      req.basic_auth("", Castle.config.api_secret)
      req.body = args.to_json
      response = @http.request(req)
      JSON.parse(response.body, :symbolize_names => true)
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

      JSON.generate(headers)
    end
  end
end

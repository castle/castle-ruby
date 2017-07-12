# frozen_string_literal: true

module Castle
  class Client
    attr_accessor :do_not_track, :api

    def initialize(request, response)
      @do_not_track = false
      cookie_id = extract_cookie(request, response)['__cid'] || ''
      ip = request.ip
      headers = header_string(request)

      @api = API.new(cookie_id, ip, headers)
    end

    def fetch_review(id)
      @api.request("reviews/#{id}", nil, method: :get)
    end

    def identify(args)
      @api.request('identify', args) unless do_not_track?
    end

    def authenticate(args)
      @api.request('authenticate', args)
    end

    def track(args)
      @api.request('track', args) unless do_not_track?
    end

    def do_not_track!
      @do_not_track = true
    end

    def track!
      @do_not_track = false
    end

    def do_not_track?
      @do_not_track
    end

    private

    # Extract the cookie set by the Castle Javascript
    def extract_cookie(request, response)
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
        { name => request.env[header] } unless scrub_headers.include?(name)
      end.compact.inject(:merge)

      JSON.generate(headers || {})
    end
  end
end

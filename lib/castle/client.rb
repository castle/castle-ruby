# frozen_string_literal: true

module Castle
  class Client
    attr_accessor :api

    def initialize(request, response)
      @do_not_track = false
      cookie_id = Extractors::Cookie.new(request).extract(response, '__cid')
      ip = Extractors::Ip.new(request).extract
      headers = Extractors::Headers.new(request).extract
      @api = API.new(cookie_id, ip, headers)
    end

    def fetch_review(id)
      @api.request_query("reviews/#{id}")
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
  end
end

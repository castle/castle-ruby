# frozen_string_literal: true

module Castle
  class Client
    attr_accessor :api

    def initialize(request, cookies = request.cookies)
      @do_not_track = false
      client_id = Extractors::ClientId.new(request, cookies).call('__cid')
      ip = Extractors::IP.new(request).call
      headers = Extractors::Headers.new(request).call
      @api = API.new(client_id, ip, headers)
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

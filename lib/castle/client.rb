# frozen_string_literal: true

module Castle
  class Client
    attr_accessor :api

    def initialize(request, options = {})
      @do_not_track = default_tracking(options)
      cookies = options[:cookies] || request.cookies
      client_id = Extractors::ClientId.new(request, cookies).call('__cid')
      ip = Extractors::IP.new(request).call
      headers = Extractors::Headers.new(request).call
      @api = API.new(client_id, ip, headers)
    end

    def fetch_review(id)
      @api.request_query("reviews/#{id}")
    end

    def identify(args)
      @api.request('identify', args) if tracked?
    end

    def authenticate(args)
      @api.request('authenticate', args)
    end

    def track(args)
      @api.request('track', args) if tracked?
    end

    def disable_tracking
      @do_not_track = true
    end

    def enable_tracking
      @do_not_track = false
    end

    def tracked?
      !@do_not_track
    end

    private

    def default_tracking(options)
      options.key?(:do_not_track) ? options[:do_not_track] : false
    end
  end
end

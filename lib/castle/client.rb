# frozen_string_literal: true

module Castle
  class Client
    attr_accessor :api

    def initialize(request, options = {})
      @do_not_track = default_tracking(options)
      @context = options[:context] || {}
      cookies = options[:cookies] || request.cookies
      @castle_headers = build_castle_headers(request, cookies)
      @api = API.new(@castle_headers)
    end

    def fetch_review(review_id)
      @api.request_query("reviews/#{review_id}")
    end

    def identify(event, options = {})
      return unless tracked?
      command = Castle::Commands::Identify.new(@context).build(event, options || {})
      @api.request(command)
    end

    def authenticate(event, user_id, options = {})
      return unless tracked?
      command = Castle::Commands::Authenticate.new(@context).build(event, user_id, options || {})
      @api.request(command)
    end

    def track(event, options = {})
      return unless tracked?
      command = Castle::Commands::Track.new(@context).build(event, options || {})
      @api.request(command)
    end

    def page(name, options = {})
      return unless tracked?
      command = Castle::Commands::Page.new(@context).build(name, options || {})
      @api.request(command)
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

    def build_castle_headers(request, cookies)
      client_id = Extractors::ClientId.new(request, cookies).call('__cid')
      ip = Extractors::IP.new(request).call
      request_headers = Extractors::Headers.new(request).call
      Castle::Headers.new.prepare(client_id, ip, request_headers)
    end

    def default_tracking(options)
      options.key?(:do_not_track) ? options[:do_not_track] : false
    end
  end
end

# frozen_string_literal: true

module Castle
  class Client
    attr_accessor :api

    def initialize(request, options = {})
      @do_not_track = default_tracking(options)
      request_headers = Extractors::Headers.new(request).call
      ip = Extractors::IP.new(request).call
      @context = setup_context(request_headers, ip, options[:context])
      @castle_headers = setup_castle_headers(request, request_headers, ip, options[:cookies])
      @api = API.new(@castle_headers)
    end

    def fetch_review(review_id)
      @api.request_query("reviews/#{review_id}")
    end

    def identify(options = {})
      return unless tracked?
      command = Castle::Commands::Identify.new(@context).build(options || {})
      @api.request(command)
    end

    def authenticate(options = {})
      return unless tracked?
      command = Castle::Commands::Authenticate.new(@context).build(options || {})
      @api.request(command)
    end

    def track(options = {})
      return unless tracked?
      command = Castle::Commands::Track.new(@context).build(options || {})
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

    def setup_context(request_headers, ip, additional_context)
      default_context = Castle::DefaultContext.new(request_headers, ip).call
      Castle::ContextMerger.new(default_context).call(additional_context || {})
    end

    def setup_castle_headers(request, request_headers, ip, cookies)
      client_id = Extractors::ClientId.new(request, cookies || request.cookies).call('__cid')
      Castle::Headers.new.prepare(client_id, ip, request_headers)
    end

    def default_tracking(options)
      options.key?(:do_not_track) ? options[:do_not_track] : false
    end
  end
end

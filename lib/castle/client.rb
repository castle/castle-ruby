# frozen_string_literal: true

module Castle
  class Client
    attr_accessor :api

    def initialize(request, options = {})
      @do_not_track = default_tracking(options)
      @context = setup_context(request, options[:cookies], options[:context])
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

    def setup_context(request, cookies, additional_context)
      default_context = Castle::DefaultContext.new(request, cookies).call
      Castle::ContextMerger.new(default_context).call(additional_context || {})
    end

    def default_tracking(options)
      options.key?(:do_not_track) ? options[:do_not_track] : false
    end
  end
end

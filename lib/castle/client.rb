# frozen_string_literal: true

module Castle
  class Client
    attr_accessor :api

    def initialize(request, options = {})
      @do_not_track = default_tracking(options)
      @context = setup_context(request, options[:cookies], options[:context])
      @api = API.new
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
      if tracked?
        command = Castle::Commands::Authenticate.new(@context).build(options || {})
        begin
          @api.request(command).merge('failover' => false, 'failover_reason' => nil)
        rescue Castle::RequestError, Castle::InternalServerError => error
          failover_response_or_raise(FailoverAuthResponse.new(options[:user_id], reason: error.to_s), error)
        end
      else
        FailoverAuthResponse.new(options[:user_id], strategy: :allow, reason: 'Castle set to do not track.').generate
      end
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

    def failover_response_or_raise(failover_response, error)
      return failover_response.generate unless Castle.config.failover_strategy == :throw
      raise error
    end

    def default_tracking(options)
      options.key?(:do_not_track) ? options[:do_not_track] : false
    end
  end
end

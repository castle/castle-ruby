# frozen_string_literal: true

module Castle
  class Client
    class << self
      def from_request(request, options = {})
        new(to_context(request, options), options[:do_not_track])
      end

      def to_context(request, options = {})
        default_context = Castle::DefaultContext.new(request, options[:cookies]).call
        Castle::ContextMerger.new(default_context).call(options[:context] || {})
      end
    end

    attr_accessor :api

    def initialize(context, do_not_track = false)
      @do_not_track = do_not_track
      @context = context
      @api = API.new
    end

    def authenticate(options = {})
      options = Castle::Utils.deep_symbolize_keys(options || {})

      if tracked?
        command = Castle::Commands::Authenticate.new(@context).build(options)
        begin
          @api.request(command).merge(failover: false, failover_reason: nil)
        rescue Castle::RequestError, Castle::InternalServerError => error
          failover_response_or_raise(FailoverAuthResponse.new(options[:user_id], reason: error.to_s), error)
        end
      else
        FailoverAuthResponse.new(options[:user_id], strategy: :allow, reason: 'Castle set to do not track.').generate
      end
    end

    def identify(options = {})
      options = Castle::Utils.deep_symbolize_keys(options || {})

      return unless tracked?

      command = Castle::Commands::Identify.new(@context).build(options)
      @api.request(command)
    end

    def track(options = {})
      options = Castle::Utils.deep_symbolize_keys(options || {})

      return unless tracked?

      command = Castle::Commands::Track.new(@context).build(options)
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
  end
end

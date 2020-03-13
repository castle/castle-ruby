# frozen_string_literal: true

module Castle
  class Client
    class << self
      def from_request(request, options = {})
        new(
          to_context(request, options),
          to_options(options)
        )
      end

      def to_context(request, options = {})
        default_context = Castle::Context::Default.new(request, options[:cookies]).call
        Castle::Context::Merger.call(default_context, options[:context])
      end

      def to_options(options = {})
        options[:timestamp] ||= Castle::Utils::Timestamp.call
        warn '[DEPRECATION] use user_traits instead of traits key' if options.key?(:traits)
        options
      end

      def failover_response_or_raise(failover_response, error)
        return failover_response.generate unless Castle.config.failover_strategy == :throw

        raise error
      end
    end

    attr_accessor :context

    def initialize(context, options = {})
      @do_not_track = options.fetch(:do_not_track, false)
      @timestamp = options[:timestamp]
      @context = context
    end

    def authenticate(options = {})
      options = Castle::Utils.deep_symbolize_keys(options || {})

      return generate_do_not_track_response(options[:user_id]) unless tracked?

      add_timestamp_if_necessary(options)
      command = Castle::Commands::Authenticate.new(@context).build(options)
      begin
        Castle::API.request(command).merge(failover: false, failover_reason: nil)
      rescue Castle::RequestError, Castle::InternalServerError => e
        self.class.failover_response_or_raise(
          FailoverAuthResponse.new(options[:user_id], reason: e.to_s), e
        )
      end
    end

    def identify(options = {})
      options = Castle::Utils.deep_symbolize_keys(options || {})

      return unless tracked?

      add_timestamp_if_necessary(options)

      command = Castle::Commands::Identify.new(@context).build(options)
      Castle::API.request(command)
    end

    def track(options = {})
      options = Castle::Utils.deep_symbolize_keys(options || {})

      return unless tracked?

      add_timestamp_if_necessary(options)

      command = Castle::Commands::Track.new(@context).build(options)
      Castle::API.request(command)
    end

    def impersonate(options = {})
      options = Castle::Utils.deep_symbolize_keys(options || {})
      add_timestamp_if_necessary(options)
      command = Castle::Commands::Impersonate.new(@context).build(options)
      Castle::API.request(command).tap do |response|
        raise Castle::ImpersonationFailed unless response[:success]
      end
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

    def generate_do_not_track_response(user_id)
      FailoverAuthResponse.new(
        user_id,
        strategy: :allow, reason: 'Castle is set to do not track.'
      ).generate
    end

    def add_timestamp_if_necessary(options)
      options[:timestamp] ||= @timestamp if @timestamp
    end
  end
end

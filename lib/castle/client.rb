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
        default_context = Castle::Context::GetDefault.new(request, options[:cookies]).call
        Castle::Context::Merge.call(default_context, options[:context])
      end

      def to_options(options = {})
        options[:timestamp] ||= Castle::Utils::GetTimestamp.call
        warn '[DEPRECATION] use user_traits instead of traits key' if options.key?(:traits)
        options
      end
    end

    attr_accessor :context

    def initialize(context, options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})
      @do_not_track = options.fetch(:do_not_track, false)
      @timestamp = options[:timestamp]
      @context = context
    end

    def authenticate(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

      return generate_do_not_track_response(options[:user_id]) unless tracked?

      add_timestamp_if_necessary(options)

      Castle::API::Authenticate.call(@context, options)
    end

    def identify(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

      return unless tracked?

      add_timestamp_if_necessary(options)

      Castle::API::Identify.call(@context, options)
    end

    def track(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

      return unless tracked?

      add_timestamp_if_necessary(options)

      Castle::API::Track.call(@context, options)
    end

    def impersonate(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

      add_timestamp_if_necessary(options)

      Castle::API::Impersonate.call(@context, options)
    end

    def review(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

      add_timestamp_if_necessary(options)

      Castle::API::Review.call(@context, options)
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
      Castle::Failover::PrepareResponse.new(
        user_id,
        strategy: :allow, reason: 'Castle is set to do not track.'
      ).call
    end

    def add_timestamp_if_necessary(options)
      options[:timestamp] ||= @timestamp if @timestamp
    end
  end
end

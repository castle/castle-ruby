# frozen_string_literal: true

module Castle
  class Client
    class << self
      def from_request(request, options = {})
        new(
          options.merge(context: Castle::Context::Prepare.call(request, options))
        )
      end
    end

    attr_accessor :context

    def initialize(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})
      @do_not_track = options.fetch(:do_not_track, false)
      @timestamp = options.fetch(:timestamp, Castle::Utils::GetTimestamp.call)
      @context = options[:context]
    end

    def authenticate(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

      return generate_do_not_track_response(options[:user_id]) unless tracked?

      add_timestamp_if_necessary(options)

      new_context = Castle::Context::Merge.call(@context, options[:context])

      Castle::API::Authenticate.call(options.merge(context: new_context, no_symbolize: true))
    end

    def identify(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

      return unless tracked?

      add_timestamp_if_necessary(options)

      new_context = Castle::Context::Merge.call(@context, options[:context])

      Castle::API::Identify.call(options.merge(context: new_context, no_symbolize: true))
    end

    def track(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

      return unless tracked?

      add_timestamp_if_necessary(options)

      new_context = Castle::Context::Merge.call(@context, options[:context])

      Castle::API::Track.call(options.merge(context: new_context, no_symbolize: true))
    end

    def impersonate(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

      add_timestamp_if_necessary(options)

      new_context = Castle::Context::Merge.call(@context, options[:context])

      Castle::API::Impersonate.call(options.merge(context: new_context, no_symbolize: true))
    end

    def review(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

      Castle::API::Review.call(options.merge(no_symbolize: true))
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

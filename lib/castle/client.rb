# frozen_string_literal: true

module Castle
  # Castle's client.
  class Client
    class << self
      def from_request(request, options = {})
        new(options.merge(context: Castle::Context::Prepare.call(request, options)))
      end
    end

    attr_accessor :context

    # @param options [Hash]
    def initialize(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})
      @do_not_track = options.fetch(:do_not_track, false)
      @timestamp = options.fetch(:timestamp) { Castle::Utils::GetTimestamp.call }
      @context = options.fetch(:context) { {} }
    end

    # @param options [Hash]
    def authenticate(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

      return generate_do_not_track_response(options[:user_id]) unless tracked?

      add_timestamp_if_necessary(options)

      new_context = Castle::Context::Merge.call(@context, options[:context])

      Castle::API::Authenticate.call(options.merge(context: new_context, no_symbolize: true))
    end

    # @param options [Hash]
    def track(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

      return unless tracked?

      add_timestamp_if_necessary(options)

      new_context = Castle::Context::Merge.call(@context, options[:context])

      Castle::API::Track.call(options.merge(context: new_context, no_symbolize: true))
    end

    # @param options [Hash]
    def filter(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

      return generate_do_not_track_response(options[:user][:id]) unless tracked?

      add_timestamp_if_necessary(options)

      new_context = Castle::Context::Merge.call(@context, options[:context])

      Castle::API::Filter.call(options.merge(context: new_context, no_symbolize: true))
    end

    # @param options [Hash]
    def risk(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

      return generate_do_not_track_response(options[:user][:id]) unless tracked?

      add_timestamp_if_necessary(options)

      new_context = Castle::Context::Merge.call(@context, options[:context])

      Castle::API::Risk.call(options.merge(context: new_context, no_symbolize: true))
    end

    # @param options [Hash]
    def log(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

      return generate_do_not_track_response(options[:user][:id]) unless tracked?

      add_timestamp_if_necessary(options)

      new_context = Castle::Context::Merge.call(@context, options[:context])

      Castle::API::Log.call(options.merge(context: new_context, no_symbolize: true))
    end

    # @param options [Hash]
    def start_impersonation(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

      add_timestamp_if_necessary(options)

      new_context = Castle::Context::Merge.call(@context, options[:context])

      Castle::API::StartImpersonation.call(options.merge(context: new_context, no_symbolize: true))
    end

    # @param options [Hash]
    def end_impersonation(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

      add_timestamp_if_necessary(options)

      new_context = Castle::Context::Merge.call(@context, options[:context])

      Castle::API::EndImpersonation.call(options.merge(context: new_context, no_symbolize: true))
    end

    def disable_tracking
      @do_not_track = true
    end

    def enable_tracking
      @do_not_track = false
    end

    # @return [Boolean]
    def tracked?
      !@do_not_track
    end

    private

    # @param user_id [String, Boolean]
    def generate_do_not_track_response(user_id)
      Castle::Failover::PrepareResponse.new(user_id, strategy: :allow, reason: 'Castle is set to do not track.').call
    end

    # @param options [Hash]
    def add_timestamp_if_necessary(options)
      options[:timestamp] ||= @timestamp if @timestamp
    end
  end
end

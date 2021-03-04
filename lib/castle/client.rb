# frozen_string_literal: true

module Castle
  class Client
    class << self
      def from_request(request, options = {})
        default_options = Castle::Options::GetDefault.new(request, options[:cookies]).call
        options_with_default_opts = Castle::Options::Merge.call(options, default_options)
        new(
          options_with_default_opts.merge(context: Castle::Context::Prepare.call(request, options))
        )
      end
    end

    attr_accessor :context

    # @param options [Hash]
    def initialize(options = {})
      @default_options = Castle::Utils::DeepSymbolizeKeys.call(options || {})
      @do_not_track = options.fetch(:do_not_track, false)
      @timestamp = options.fetch(:timestamp) { Castle::Utils::GetTimestamp.call }
      @context = options.fetch(:context) { {} }
    end

    # @param options [Hash]
    def authenticate(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})
      options_with_default_opts = Castle::Options::Merge.call(options, @default_options)

      return generate_do_not_track_response(options[:user_id]) unless tracked?

      add_timestamp_if_necessary(options_with_default_opts)

      new_context = Castle::Context::Merge.call(@context, options_with_default_opts[:context])

      Castle::API::Authenticate.call(
        options_with_default_opts.merge(context: new_context, no_symbolize: true)
      )
    end

    # @param options [Hash]
    def track(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})
      options_with_default_opts = Castle::Options::Merge.call(options, @default_options)

      return unless tracked?

      add_timestamp_if_necessary(options_with_default_opts)

      new_context = Castle::Context::Merge.call(@context, options_with_default_opts[:context])

      Castle::API::Track.call(
        options_with_default_opts.merge(context: new_context, no_symbolize: true)
      )
    end

    # @param options [Hash]
    def start_impersonation(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})
      options_with_default_opts = Castle::Options::Merge.call(options, @default_options)

      add_timestamp_if_necessary(options)

      new_context = Castle::Context::Merge.call(@context, options_with_default_opts[:context])

      Castle::API::StartImpersonation.call(
        options_with_default_opts.merge(context: new_context, no_symbolize: true)
      )
    end

    # @param options [Hash]
    def end_impersonation(options = {})
      options = Castle::Utils::DeepSymbolizeKeys.call(options || {})
      options_with_default_opts = Castle::Options::Merge.call(options, @default_options)

      add_timestamp_if_necessary(options_with_default_opts)

      new_context = Castle::Context::Merge.call(@context, options_with_default_opts[:context])

      Castle::API::EndImpersonation.call(
        options_with_default_opts.merge(context: new_context, no_symbolize: true)
      )
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

    # @param user_id [String|Boolean]
    def generate_do_not_track_response(user_id)
      Castle::Failover::PrepareResponse.new(
        user_id,
        strategy: :allow,
        reason: 'Castle is set to do not track.'
      ).call
    end

    # @param options [Hash]
    def add_timestamp_if_necessary(options)
      options[:timestamp] ||= @timestamp if @timestamp
    end
  end
end

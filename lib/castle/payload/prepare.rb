# frozen_string_literal: true

module Castle
  module Payload
    # prepares payload based on the request
    module Prepare
      class << self
        # @param payload_options [Hash]
        # @param request [Request]
        # @param options [Hash] required for context preparation
        # @return [Hash]
        def call(payload_options, request, options = {})
          default_options = Castle::Options::GetDefault.new(request, options[:cookies]).call
          options_with_default_opts = Castle::Options::Merge.call(options, default_options)
          options_for_payload =
            Castle::Options::Merge.call(payload_options, options_with_default_opts)

          context = Castle::Context::Prepare.call(options_for_payload)
          payload =
            Castle::Utils::DeepSymbolizeKeys
              .call(options_for_payload || {})
              .merge(context: context)
          payload[:timestamp] ||= Castle::Utils::GetTimestamp.call

          warn '[DEPRECATION] use user_traits instead of traits key' if payload.key?(:traits)

          payload
        end
      end
    end
  end
end

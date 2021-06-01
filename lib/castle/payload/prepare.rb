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
          context = Castle::Context::Prepare.call(request, payload_options.merge(options))

          payload =
            Castle::Utils::DeepSymbolizeKeys.call(payload_options || {}).merge(context: context)
          payload[:timestamp] ||= Castle::Utils::GetTimestamp.call

          warn '[DEPRECATION] use user_traits instead of traits key' if payload.key?(:traits)

          payload
        end
      end
    end
  end
end

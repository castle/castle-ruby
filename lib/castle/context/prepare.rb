# frozen_string_literal: true

module Castle
  module Context
    # prepares the context from the request
    module Prepare
      class << self
        # @param request [Request]
        # @param options [Hash]
        # @return [Hash]
        def call(request, options = {})
          default_context = Castle::Context::GetDefault.new(request, options[:cookies]).call
          Castle::Context::Merge.call(default_context, options[:context])
        end
      end
    end
  end
end

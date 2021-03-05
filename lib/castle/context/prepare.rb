# frozen_string_literal: true

module Castle
  module Context
    # prepares the context from the request
    module Prepare
      class << self
        # @param options [Hash]
        # @return [Hash]
        def call(options = {})
          default_context = Castle::Context::GetDefault.call
          Castle::Context::Merge.call(default_context, options[:context])
        end
      end
    end
  end
end

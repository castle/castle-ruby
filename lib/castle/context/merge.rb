# frozen_string_literal: true

module Castle
  module Context
    # merges initial request context with request context
    class Merge
      class << self
        # @param initial_context [Hash]
        # @param request_context [Hash]
        def call(initial_context, request_context)
          main_context = Castle::Utils::Clone.call(initial_context)
          Castle::Utils::Merge.call(main_context, request_context || {})
        end
      end
    end
  end
end

# frozen_string_literal: true

module Castle
  class ContextMerger
    def initialize(context)
      @context = context
    end

    def call(request_context)
      request_context
    end
  end
end

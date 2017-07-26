# frozen_string_literal: true

module Castle
  class ContextMerger
    def initialize(context)
      @main_context = Castle::Utils::Cloner.call(context)
    end

    def call(request_context)
      Castle::Utils::Merger.call(@main_context, request_context)
    end
  end
end

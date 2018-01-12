# frozen_string_literal: true

module Castle
  class ContextMerger
    class << self
      def call(initial_context, request_context)
        main_context = Castle::Utils::Cloner.call(initial_context)
        Castle::Utils::Merger.call(main_context, request_context || {})
      end
    end
  end
end

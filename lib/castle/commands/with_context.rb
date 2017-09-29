# frozen_string_literal: true

module Castle
  module Commands
    module WithContext
      def initialize(context)
        @context_merger = ContextMerger.new(context)
      end

      private

      def build_context(request_context)
        @context_merger.call(request_context || {})
      end
    end
  end
end

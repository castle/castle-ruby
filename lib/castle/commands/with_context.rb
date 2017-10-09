# frozen_string_literal: true

module Castle
  module Commands
    module WithContext
      def initialize(context)
        @context_merger = ContextMerger.new(context)
      end

      private

      def build_context!(options)
        sanitize_active_mode!(options)
        options[:context] = merge_context(options[:context])
      end

      def sanitize_active_mode!(options)
        return unless options[:context] && options[:context].key?(:active)
        return if [true, false].include?(options[:context][:active])
        options[:context].delete(:active)
      end

      def merge_context(request_context)
        @context_merger.call(request_context || {})
      end
    end
  end
end

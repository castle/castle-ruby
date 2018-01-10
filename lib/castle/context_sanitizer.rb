# frozen_string_literal: true

module Castle
  class ContextSanitizer
    class << self
      def call(context)
        sanitized_active_mode(context) || {}
      end

      private

      def sanitized_active_mode(context)
        return context unless context && context.key?(:active)
        return context if [true, false].include?(context[:active])
        context.reject { |key| key == :active }
      end
    end
  end
end

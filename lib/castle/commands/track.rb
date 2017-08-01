# frozen_string_literal: true

module Castle
  module Commands
    class Track
      def initialize(context)
        @context_merger = ContextMerger.new(context)
      end

      def build(options = {})
        event = options[:event]
        raise Castle::InvalidParametersError if event.nil? || event.to_s.empty?
        request_args = {
          event: event,
          context: build_context(options[:context])
        }
        request_args[:user_id] = options[:user_id] if options.key?(:user_id)
        request_args[:properties] = options[:properties] if options.key?(:properties)

        Castle::Command.new('track', request_args, :post)
      end

      private

      def build_context(request_context)
        @context_merger.call(request_context || {})
      end
    end
  end
end

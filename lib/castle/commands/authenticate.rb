# frozen_string_literal: true

module Castle
  module Commands
    class Authenticate
      def initialize(context)
        @context_merger = ContextMerger.new(context)
      end

      def build(options = {})
        event, user_id = required_data(options)

        args = {
          event: event,
          user_id: user_id,
          context: build_context(options[:context])
        }

        args[:properties] = options[:properties] if options.key?(:properties)
        args[:traits] = options[:traits] if options.key?(:traits)
        args[:context][:active] = true if args[:context].key?(:active) && args[:context][:active]

        Castle::Command.new('authenticate', args, :post)
      end

      private

      def build_context(request_context)
        @context_merger.call(request_context || {})
      end

      def required_data(options)
        event = options[:event].to_s
        user_id = options[:user_id].to_s

        raise Castle::InvalidParametersError if event.empty? || user_id.empty?

        [event, user_id]
      end
    end
  end
end

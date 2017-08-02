# frozen_string_literal: true

module Castle
  module Commands
    class Authenticate
      def initialize(context)
        @context_merger = ContextMerger.new(context)
      end

      def build(options = {})
        event, user_id = required_data(options)
        request_args = {
          event: event,
          user_id: user_id,
          context: build_context(options[:context])
        }
        request_args[:properties] = options[:properties] if options.key?(:properties)

        Castle::Command.new('authenticate', request_args, :post)
      end

      private

      def build_context(request_context)
        @context_merger.call(request_context || {})
      end

      def required_data(options)
        event = options[:event]
        user_id = options[:user_id]
        raise Castle::InvalidParametersError if event.nil? || event.to_s.empty? ||
                                                user_id.nil? || user_id.to_s.empty?

        [event, user_id]
      end
    end
  end
end

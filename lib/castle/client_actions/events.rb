# frozen_string_literal: true

module Castle
  module ClientActions
    # Client actions for the Events API
    module Events
      # @param options [Hash]
      def events_schema(options = {})
        Castle::API::Events::Schema.call(options)
      end

      # @param options [Hash]
      def query_events(options = {})
        Castle::API::Events::Query.call(options)
      end

      # @param options [Hash]
      def group_events(options = {})
        Castle::API::Events::Group.call(options)
      end
    end
  end
end

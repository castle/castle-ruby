# frozen_string_literal: true

module Castle
  module Commands
    class Authenticate
      include WithContext

      def build(options = {})
        event, user_id = required_data(options)

        if options[:context] && options[:context].key?(:active)
          unless [true, false].include?(options[:context][:active])
            options[:context].delete(:active)
          end
        end

        args = {
          event: event,
          user_id: user_id,
          context: build_context(options[:context])
        }

        args[:properties] = options[:properties] if options.key?(:properties)
        args[:traits] = options[:traits] if options.key?(:traits)

        Castle::Command.new('authenticate', args, :post)
      end

      private

      def required_data(options)
        event = options[:event].to_s
        user_id = options[:user_id].to_s

        raise Castle::InvalidParametersError if event.empty? || user_id.empty?

        [event, user_id]
      end
    end
  end
end

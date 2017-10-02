# frozen_string_literal: true

module Castle
  module Commands
    class Authenticate
      include WithContext

      def build(options = {})
        validate!(options)

        if options[:context] && options[:context].key?(:active)
          unless [true, false].include?(options[:context][:active])
            options[:context].delete(:active)
          end
        end

        args = {
          event: options[:event],
          user_id: options[:user_id],
          context: build_context(options[:context])
        }

        args[:properties] = options[:properties] if options.key?(:properties)
        args[:traits] = options[:traits] if options.key?(:traits)

        Castle::Command.new('authenticate', args, :post)
      end

      private

      def validate!(options)
        %i[event user_id].each do |key|
          next unless options[key].to_s.empty?
          raise Castle::InvalidParametersError, "#{key} is missing or empty"
        end
      end
    end
  end
end

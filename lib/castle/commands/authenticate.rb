# frozen_string_literal: true

module Castle
  module Commands
    class Authenticate
      def initialize(context)
        @context = context
      end

      def build(options = {})
        validate!(options)
        context = ContextMerger.call(@context, options[:context])
        context = ContextSanitizer.call(context)

        Castle::Command.new('authenticate',
                            options.merge(context: context, sent_at: Time.now.iso8601),
                            :post)
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

# frozen_string_literal: true

module Castle
  module Commands
    class Track
      def initialize(context)
        @context = context
      end

      def build(options = {})
        validate!(options)
        context = ContextMerger.call(@context, options[:context])
        context = ContextSanitizer.call(context)

        Castle::Command.new('track',
                            options.merge(context: context, sent_at: Time.now.iso8601),
                            :post)
      end

      private

      def validate!(options)
        %i[event].each do |key|
          next unless options[key].to_s.empty?
          raise Castle::InvalidParametersError, "#{key} is missing or empty"
        end
      end
    end
  end
end

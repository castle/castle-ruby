# frozen_string_literal: true

module Castle
  module Commands
    # builder for impersonate command
    class Impersonate
      def initialize(context)
        @context = context
      end

      def build(options = {})
        validate!(options)
        context = ContextMerger.call(@context, options[:context])
        context = ContextSanitizer.call(context)

        Castle::Command.new('impersonate',
                            options.merge(context: context,
                                          sent_at: Castle::Utils::Timestamp.call),
                            :post)
      end

      private

      def validate!(options)
        %i[user_id].each do |key|
          next unless options[key].to_s.empty?
          raise Castle::InvalidParametersError, "#{key} is missing or empty"
        end
      end
    end
  end
end

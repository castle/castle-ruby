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
        context = Castle::Context::Merger.call(@context, options[:context])
        context = Castle::Context::Sanitizer.call(context)

        validate_context!(context)

        Castle::Command.new('impersonate',
                            options.merge(context: context),
                            :post)
      end

      private

      def validate!(options)
        %i[user_id].each do |key|
          next unless options[key].to_s.empty?
          raise Castle::InvalidParametersError, "#{key} is missing or empty"
        end
      end

      def validate_context!(context)
        %i[user_agent ip].each do |key|
          next unless context[key].to_s.empty?
          raise Castle::InvalidParametersError, "#{key} is missing or empty"
        end
      end
    end
  end
end

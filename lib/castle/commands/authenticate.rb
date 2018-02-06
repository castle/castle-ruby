# frozen_string_literal: true

module Castle
  module Commands
    class Authenticate
      def initialize(context)
        @context = context
      end

      def build(options = {})
        validate!(options)
        context = Castle::Context::Merger.call(@context, options[:context])
        context = Castle::Context::Sanitizer.call(context)

        Castle::Command.new('authenticate',
                            options.merge(context: context,
                                          sent_at: Castle::Utils::Timestamp.call),
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

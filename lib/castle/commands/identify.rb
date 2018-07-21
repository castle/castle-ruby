# frozen_string_literal: true

module Castle
  module Commands
    class Identify
      def initialize(context)
        @context = context
      end

      def build(options = {})
        Castle::Validators::NotSupported.call(options, %i[properties])
        context = Castle::Context::Merger.call(@context, options[:context])
        context = Castle::Context::Sanitizer.call(context)

        Castle::Command.new(
          'identify',
          options.merge(context: context, sent_at: Castle::Utils::Timestamp.call),
          :post
        )
      end
    end
  end
end

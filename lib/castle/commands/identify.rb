# frozen_string_literal: true

module Castle
  module Commands
    class Identify
      def initialize(context)
        @context = context
      end

      def build(options = {})
        Castle::Validators::NotSupported.call(options, %i[properties])
        context = Castle::Context::Merge.call(@context, options[:context])
        context = Castle::Context::Sanitize.call(context)

        Castle::Command.new(
          'identify',
          options.merge(context: context, sent_at: Castle::Utils::GetTimestamp.call),
          :post
        )
      end
    end
  end
end

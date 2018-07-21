# frozen_string_literal: true

module Castle
  module Commands
    class Authenticate
      def initialize(context)
        @context = context
      end

      def build(options = {})
        Castle::Validators::Present.call(options, %i[event])
        context = Castle::Context::Merger.call(@context, options[:context])
        context = Castle::Context::Sanitizer.call(context)

        Castle::Command.new(
          'authenticate',
          options.merge(context: context, sent_at: Castle::Utils::Timestamp.call),
          :post
        )
      end
    end
  end
end

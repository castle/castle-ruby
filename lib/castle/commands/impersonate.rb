# frozen_string_literal: true

module Castle
  module Commands
    # builder for impersonate command
    class Impersonate
      def initialize(context)
        @context = context
      end

      def build(options = {})
        Castle::Validators::Present.call(options, %i[user_id])
        context = Castle::Context::Merge.call(@context, options[:context])
        context = Castle::Context::Sanitize.call(context)

        Castle::Validators::Present.call(context, %i[user_agent ip])

        Castle::Command.new(
          'impersonate',
          options.merge(context: context, sent_at: Castle::Utils::GetTimestamp.call),
          options[:reset] ? :delete : :post
        )
      end
    end
  end
end

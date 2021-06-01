# frozen_string_literal: true

module Castle
  module Commands
    # builder for impersonate command
    class StartImpersonation
      class << self
        # @param options [Hash]
        # @return [Castle::Command]
        def build(options = {})
          Castle::Validators::Present.call(options, %i[user_id])
          context = Castle::Context::Sanitize.call(options[:context])

          Castle::Validators::Present.call(context, %i[user_agent ip])

          Castle::Command.new(
            'impersonate',
            options.merge(context: context, sent_at: Castle::Utils::GetTimestamp.call),
            :post
          )
        end
      end
    end
  end
end

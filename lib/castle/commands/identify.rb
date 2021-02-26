# frozen_string_literal: true

module Castle
  module Commands
    class Identify
      class << self
        # @param options [Hash]
        # @return [Castle::Command]
        def build(options = {})
          Castle::Validators::NotSupported.call(options, %i[properties])
          context = Castle::Context::Sanitize.call(options[:context])

          Castle::Command.new(
            'identify',
            options.merge(
              context: context,
              sent_at: Castle::Utils::GetTimestamp.call
            ),
            :post
          )
        end
      end
    end
  end
end

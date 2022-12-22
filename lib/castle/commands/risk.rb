# frozen_string_literal: true

module Castle
  module Commands
    # Generates the payload for the risk request
    class Risk
      class << self
        # @param options [Hash]
        # @return [Castle::Command]
        def build(options = {})
          context = Castle::Context::Sanitize.call(options[:context])

          Castle::Command.new('risk', options.merge(context: context, sent_at: Castle::Utils::GetTimestamp.call), :post)
        end
      end
    end
  end
end

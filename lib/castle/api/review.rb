# frozen_string_literal: true

module Castle
  module API
    module Review
      class << self
        # @param options [Hash]
        # return [Hash]
        def call(options = {})
          options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

          Castle::API.call(
            Castle::Commands::Review.build(options),
            {},
            options[:http]
          )
        end
      end
    end
  end
end

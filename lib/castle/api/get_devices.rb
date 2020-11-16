# frozen_string_literal: true

module Castle
  module API
    # Sends GET #{user_id}/devices request
    module GetDevices
      class << self
        # @param options [Hash]
        # return [Hash]
        def call(options = {})
          options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

          Castle::API.call(
            Castle::Commands::GetDevices.build(options),
            {},
            options[:http]
          )
        end
      end
    end
  end
end

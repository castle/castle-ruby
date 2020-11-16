# frozen_string_literal: true

module Castle
  module API
    # Sends GET devices/#{device_token} request
    module GetDevice
      class << self
        # @param options [Hash]
        # return [Hash]
        def call(options = {})
          options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

          Castle::API.call(
            Castle::Commands::GetDevice.build(options),
            {},
            options[:http]
          )
        end
      end
    end
  end
end

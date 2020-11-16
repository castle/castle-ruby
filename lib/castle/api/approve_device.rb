# frozen_string_literal: true

module Castle
  module API
    # Sends PUT devices/#{device_token}/approve request
    module ApproveDevice
      class << self
        # @param options [Hash]
        # return [Hash]
        def call(options = {})
          options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

          Castle::API.call(
            Castle::Commands::ApproveDevice.build(options),
            {},
            options[:http]
          )
        end
      end
    end
  end
end

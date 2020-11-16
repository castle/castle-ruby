# frozen_string_literal: true

module Castle
  module API
    # Sends PUT devices/#{device_token}/report request
    module ReportDevice
      class << self
        # @param options [Hash]
        # return [Hash]
        def call(options = {})
          options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

          Castle::API.call(
            Castle::Commands::ReportDevice.build(options),
            {},
            options[:http]
          )
        end
      end
    end
  end
end

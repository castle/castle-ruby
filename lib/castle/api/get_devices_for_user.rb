# frozen_string_literal: true

module Castle
  module API
    # Sends GET users/#{user_id}/devices request
    module GetDevicesForUser
      class << self
        # @param options [Hash]
        # return [Hash]
        def call(options = {})
          options = Castle::Utils::DeepSymbolizeKeys.call(options || {})

          Castle::API.call(
            Castle::Commands::GetDevicesForUser.build(options),
            {},
            options[:http]
          )
        end
      end
    end
  end
end

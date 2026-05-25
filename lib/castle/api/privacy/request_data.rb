# frozen_string_literal: true

module Castle
  module API
    module Privacy
      # Sends POST /v1/privacy/users — Castle compiles the user's data and emails it
      # to the configured privacy mailbox. Closes #261 (GDPR Article 15).
      module RequestData
        class << self
          # @param options [Hash]
          # @return [Hash]
          def call(options = {})
            options = Castle::Utils::DeepSymbolizeKeys.call(options || {})
            http = options.delete(:http)
            config = options.delete(:config) || Castle.config

            Castle::API.call(Castle::Commands::Privacy::RequestData.build(options), {}, http, config)
          end
        end
      end
    end
  end
end

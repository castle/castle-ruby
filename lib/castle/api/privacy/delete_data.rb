# frozen_string_literal: true

module Castle
  module API
    module Privacy
      # Sends DELETE /v1/privacy/users — permanently purges a user's data from Castle.
      # Closes #261 (GDPR Article 17).
      module DeleteData
        class << self
          # @param options [Hash]
          # @return [Hash]
          def call(options = {})
            options = Castle::Utils::DeepSymbolizeKeys.call(options || {})
            http = options.delete(:http)
            config = options.delete(:config) || Castle.config

            Castle::API.call(Castle::Commands::Privacy::DeleteData.build(options), {}, http, config)
          end
        end
      end
    end
  end
end

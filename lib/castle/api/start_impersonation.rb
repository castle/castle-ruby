# frozen_string_literal: true

module Castle
  module API
    # Sends POST impersonate request
    module StartImpersonation
      class << self
        # @param options [Hash]
        def call(options = {})
          unless options[:no_symbolize]
            options = Castle::Utils::DeepSymbolizeKeys.call(options || {})
          end
          options.delete(:no_symbolize)
          http = options.delete(:http)
          config = options.delete(:config) || Castle.config

          Castle::API
            .call(
              Castle::Commands::StartImpersonation.build(options),
              {},
              http,
              config
            )
            .tap do |response|
              raise Castle::ImpersonationFailed unless response[:success]
            end
        end
      end
    end
  end
end

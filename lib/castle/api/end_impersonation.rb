# frozen_string_literal: true

module Castle
  module API
    # Sends DELETE impersonate request
    module EndImpersonation
      class << self
        # @param options [Hash]
        def call(options = {})
          unless options[:no_symbolize]
            options = Castle::Utils::DeepSymbolizeKeys.call(options || {})
          end
          options.delete(:no_symbolize)
          http = options.delete(:http)
          config = options.delete(:config) || Castle.config

          Castle::API.call(
            Castle::Commands::EndImpersonation.build(options),
            {},
            http,
            config
          ).tap do |response|
            raise Castle::ImpersonationFailed unless response[:success]
          end
        end
      end
    end
  end
end

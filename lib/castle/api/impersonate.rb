# frozen_string_literal: true

module Castle
  module API
    module Impersonate
      class << self
        # @param options [Hash]
        def call(options = {})
          unless options[:no_symbolize]
            options = Castle::Utils::DeepSymbolizeKeys.call(options || {})
          end
          options.delete(:no_symbolize)
          http = options.delete(:http)

          Castle::API.call(
            Castle::Commands::Impersonate.build(options),
            {},
            http
          ).tap do |response|
            raise Castle::ImpersonationFailed unless response[:success]
          end
        end
      end
    end
  end
end

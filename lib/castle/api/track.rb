# frozen_string_literal: true

module Castle
  module API
    module Track
      class << self
        # @param options [Hash]
        def call(options = {})
          unless options[:no_symbolize]
            options = Castle::Utils::DeepSymbolizeKeys.call(options || {})
          end
          options.delete(:no_symbolize)
          http = options.delete(:http)
          config = options.delete(:config) || Castle.config

          Castle::API.call(Castle::Commands::Track.build(options), {}, http, config)
        end
      end
    end
  end
end

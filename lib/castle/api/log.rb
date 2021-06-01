# frozen_string_literal: true

module Castle
  module API
    # Module for log endpoint
    module Log
      class << self
        # @param options [Hash]
        # return [Hash]
        def call(options = {})
          unless options[:no_symbolize]
            options = Castle::Utils::DeepSymbolizeKeys.call(options || {})
          end
          options.delete(:no_symbolize)
          http = options.delete(:http)
          config = options.delete(:config) || Castle.config

          response = Castle::API.call(Castle::Commands::Log.build(options), {}, http, config)
          response.merge(failover: false, failover_reason: nil)
        rescue Castle::RequestError, Castle::InternalServerError => e
          unless config.failover_strategy == :throw
            return Castle::Failover::PrepareResponse.new(options[:user][:id], reason: e.to_s).call
          end

          raise e
        end
      end
    end
  end
end

# frozen_string_literal: true

module Castle
  module API
    # Module for risk endpoint
    module Risk
      class << self
        # @param options [Hash]
        # return [Hash]
        def call(options = {})
          options = Castle::Utils::DeepSymbolizeKeys.call(options || {}) unless options[:no_symbolize]
          options.delete(:no_symbolize)
          http = options.delete(:http)
          config = options.delete(:config) || Castle.config

          response = Castle::API.call(Castle::Commands::Risk.build(options), {}, http, config)
          response.merge(failover: false, failover_reason: nil)
        rescue Castle::RequestError, Castle::InternalServerError => e
          unless config.failover_strategy == :throw
            strategy = (config || Castle.config).failover_strategy
            return(Castle::Failover::PrepareResponse.new(options[:user][:id], reason: e.to_s, strategy: strategy).call)
          end

          raise e
        end
      end
    end
  end
end

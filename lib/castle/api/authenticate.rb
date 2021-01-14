# frozen_string_literal: true

module Castle
  module API
    module Authenticate
      class << self
        # @param options [Hash]
        # return [Hash]
        def call(options = {}, config = Castle.config)
          unless options[:no_symbolize]
            options = Castle::Utils::DeepSymbolizeKeys.call(options || {})
          end
          options.delete(:no_symbolize)
          http = options.delete(:http)

          response = Castle::API.call(
            Castle::Commands::Authenticate.build(options),
            {},
            http
          )
          response.merge(failover: false, failover_reason: nil)
        rescue Castle::RequestError, Castle::InternalServerError => e
          unless config.failover_strategy == :throw
            return Castle::Failover::PrepareResponse.new(options[:user_id], reason: e.to_s).call
          end

          raise e
        end
      end
    end
  end
end

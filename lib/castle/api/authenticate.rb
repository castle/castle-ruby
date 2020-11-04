# frozen_string_literal: true

module Castle
  module API
    module Authenticate
      class << self
        # @param context [Hash]
        # @param options [Hash]
        # return [Hash]
        def call(context, options = {})
          response = Castle::API.call(
            Castle::Commands::Authenticate.new(context).build(options),
            {},
            options[:http]
          )
          response.merge(failover: false, failover_reason: nil)
        rescue Castle::RequestError, Castle::InternalServerError => e
          unless Castle.config.failover_strategy == :throw
            return Castle::Failover::PrepareResponse.new(options[:user_id], reason: e.to_s).call
          end

          raise e
        end
      end
    end
  end
end

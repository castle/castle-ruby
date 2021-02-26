# frozen_string_literal: true

module Castle
  module Failover
    # generate failover authentication response
    class PrepareResponse
      def initialize(
        user_id,
        reason:,
        strategy: Castle.config.failover_strategy
      )
        @strategy = strategy
        @reason = reason
        @user_id = user_id
      end

      def call
        {
          action: @strategy.to_s,
          user_id: @user_id,
          failover: true,
          failover_reason: @reason
        }
      end
    end
  end
end

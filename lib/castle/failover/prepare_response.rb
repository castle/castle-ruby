# frozen_string_literal: true

module Castle
  module Failover
    # generate failover authentication response
    class PrepareResponse
      def initialize(user_id, reason:, strategy:)
        @strategy = strategy
        @reason = reason
        @user_id = user_id
      end

      def call
        {
          # v1/risk v1/filter structure
          policy: {
            action: @strategy.to_s
          },
          # v1/authenticate structure
          action: @strategy.to_s,
          user_id: @user_id,
          failover: true,
          failover_reason: @reason
        }
      end
    end
  end
end

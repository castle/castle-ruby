# frozen_string_literal: true

module Castle
  # generate failover authentication response
  class FailoverAuthResponse
    def initialize(user_id, strategy: Castle.config.failover_strategy, reason:)
      @strategy = strategy
      @reason = reason
      @user_id = user_id
    end

    def generate
      {
        'action' => @strategy.to_s,
        'user_id' => @user_id,
        'failover' => true,
        'failover_reason' => @reason
      }
    end
  end
end

# frozen_string_literal: true

module Castle
  # generate failover authentication response
  class FailoverAuthResponse
    def initialize(user_id, failover_strategy = Castle.config.failover_strategy)
      @failover_strategy = failover_strategy
      @user_id = user_id
    end

    def generate
      {
        'action' => @failover_strategy.to_s,
        'user_id' => @user_id
      }
    end
  end
end

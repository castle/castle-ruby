# frozen_string_literal: true

module Castle
  module Failover
    module Strategy
      ALLOW = :allow
      DENY = :deny
      CHALLENGE = :challenge
      THROW = :throw
    end

    STRATEGIES = %i[allow deny challenge throw].freeze
  end
end

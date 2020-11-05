# frozen_string_literal: true

module Castle
  module Failover
    # handles failover strategy consts
    module Strategy
      # allow
      ALLOW = :allow
      # deny
      DENY = :deny
      # challenge
      CHALLENGE = :challenge
      # throw an error
      THROW = :throw
    end

    # list of possible strategies
    STRATEGIES = %i[allow deny challenge throw].freeze
  end
end

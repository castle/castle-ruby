# frozen_string_literal: true

module Castle
  module Utils
    # generates proper timestamp
    class GetTimestamp
      class << self
        def call
          Time.now.utc.iso8601(3)
        end
      end
    end
  end
end

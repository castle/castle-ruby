# frozen_string_literal: true

module Castle
  module Utils
    # Generates a timestamp
    class GetTimestamp
      class << self
        # Returns current time as ISO8601 formatted string
        def call
          Time.now.utc.iso8601(3)
        end
      end
    end
  end
end

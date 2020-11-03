# frozen_string_literal: true

module Castle
  module Utils
    # generates proper timestamp
    class GenerateTimestamp
      def self.call
        Time.now.utc.iso8601(3)
      end
    end
  end
end

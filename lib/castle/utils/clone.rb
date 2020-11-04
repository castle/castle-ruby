# frozen_string_literal: true

module Castle
  module Utils
    class Clone
      def self.call(object)
        Marshal.load(Marshal.dump(object))
      end
    end
  end
end

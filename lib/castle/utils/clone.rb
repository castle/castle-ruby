# frozen_string_literal: true

module Castle
  module Utils
    # Clones any object
    class Clone
      class << self
        # Returns a cloned object of any type
        def call(object)
          Marshal.load(Marshal.dump(object))
        end
      end
    end
  end
end

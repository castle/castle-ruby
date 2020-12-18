# frozen_string_literal: true

module Castle
  module Utils
    class Clone
      class << self
        def call(object)
          Marshal.load(Marshal.dump(object))
        end
      end
    end
  end
end

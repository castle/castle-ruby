# frozen_string_literal: true

module Castle
  module Commands
    module Lists
      class All
        class << self
          # @return [Castle::Command]
          def build
            Castle::Command.new("lists", nil, :get)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Castle
  module Commands
    module Events
      # Builds the command to get the events schema
      class Schema
        class << self
          # @param options [Hash]
          # @return [Castle::Command]
          def build(_options = {})
            Castle::Command.new('events/schema', nil, :get)
          end
        end
      end
    end
  end
end

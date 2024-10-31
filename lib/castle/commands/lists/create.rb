# frozen_string_literal: true

module Castle
  module Commands
    # Commands for lists endpoints
    module Lists
      # Builds the command to create a list
      class Create
        class << self
          # @param options [Hash]
          # @return [Castle::Command]
          def build(options = {})
            Castle::Validators::Present.call(options, %i[name color primary_field])

            Castle::Command.new('lists', options, :post)
          end
        end
      end
    end
  end
end

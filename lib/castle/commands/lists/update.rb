# frozen_string_literal: true

module Castle
  module Commands
    module Lists
      # Builds the command to update a list
      class Update
        class << self
          # @param options [Hash]
          # @return [Castle::Command]
          def build(options = {})
            Castle::Validators::Present.call(options, %i[list_id])

            list_id = options.delete(:list_id)

            Castle::Command.new("lists/#{list_id}", options, :put)
          end
        end
      end
    end
  end
end

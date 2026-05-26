# frozen_string_literal: true

module Castle
  module Commands
    module ListItems
      # Builds the command to create or update multiple list items in a single call
      class CreateBatch
        class << self
          # @param options [Hash]
          # @return [Castle::Command]
          def build(options = {})
            Castle::Validators::Present.call(options, %i[list_id items])

            list_id = options.delete(:list_id)

            Castle::Command.new("lists/#{list_id}/items/batch", options, :post)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Castle
  module Commands
    module ListItems
      # Builds the command to update a list item
      class Update
        class << self
          # @param options [Hash]
          # @return [Castle::Command]
          def build(options = {})
            Castle::Validators::Present.call(options, %i[list_id list_item_id comment])
            list_id = options.delete(:list_id)
            list_item_id = options.delete(:list_item_id)

            Castle::Command.new("lists/#{list_id}/items/#{list_item_id}", options, :put)
          end
        end
      end
    end
  end
end

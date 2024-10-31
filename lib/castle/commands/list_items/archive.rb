# frozen_string_literal: true

module Castle
  module Commands
    # Commands for list items endpoints
    module ListItems
      # Generates the payload for the DELETE /lists/:list_id/items/:item_id/archive request
      class Archive
        class << self
          # @param options [Hash]
          # @return [Castle::Command]
          def build(options = {})
            Castle::Validators::Present.call(options, %i[list_id list_item_id])

            list_id = options.delete(:list_id)
            list_item_id = options.delete(:list_item_id)

            Castle::Command.new("lists/#{list_id}/items/#{list_item_id}/archive", nil, :delete)
          end
        end
      end
    end
  end
end

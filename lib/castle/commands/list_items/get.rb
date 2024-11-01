# frozen_string_literal: true

module Castle
  module Commands
    module ListItems
      # Builds the command to get a list item
      class Get
        class << self
          # @param options [Hash]
          # @return [Castle::Command]
          def build(options = {})
            Castle::Validators::Present.call(options, %i[list_id list_item_id])

            list_id = options.delete(:list_id)
            list_item_id = options.delete(:list_item_id)

            Castle::Command.new("lists/#{list_id}/items/#{list_item_id}", nil, :get)
          end
        end
      end
    end
  end
end

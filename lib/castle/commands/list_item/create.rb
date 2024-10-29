# frozen_string_literal: true

module Castle
  module Commands
    module ListItem
      class Create
        class << self
          # @param options [Hash]
          # @return [Castle::Command]
          def build(options = {})
            Castle::Validators::Present.call(options, %i[list_id author primary_value])
            # Castle::Validators::Allowed.call(options, %i[secondary_value, comment, auto_archives_at, mode])

            list_id = options.delete(:list_id)

            Castle::Command.new("lists/#{list_id}/items", options, :post)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Castle
  module Commands
    module List
      class Update
        class << self
          # @param options [Hash]
          # @return [Castle::Command]
          def build(options = {})
            Castle::Validators::Present.call(options, %i[list_id])
            # Castle::Validators::Allowed.call(options, %i[name description color default_item_archivation_time])
            # sanitize name, description, color, default_item_archivation_time

            list_id = options.delete(:list_id)

            Castle::Command.new("lists/#{list_id}", options, :put)
          end
        end
      end
    end
  end
end

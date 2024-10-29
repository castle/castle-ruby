# frozen_string_literal: true

module Castle
  module Commands
    module List
      class Create
        class << self
          # @param options [Hash]
          # @return [Castle::Command]
          def build(options = {})
            Castle::Validators::Present.call(options, %i[name color primary_field])
            # Castle::Validators::Allowed.call(options, %i[secondary_field description default_item_archivation_time])
            # sanitize secondary_field description default_item_archivation_time

            Castle::Command.new("lists", options, :post)
          end
        end
      end
    end
  end
end

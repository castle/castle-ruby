# frozen_string_literal: true

module Castle
  module Commands
    module Lists
      # Builds the command to delete a list
      class Delete
        class << self
          # @param options [Hash]
          # @return [Castle::Command]
          def build(options = {})
            Castle::Validators::Present.call(options, %i[list_id])

            Castle::Command.new("lists/#{options[:list_id]}", nil, :delete)
          end
        end
      end
    end
  end
end

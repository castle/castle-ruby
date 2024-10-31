# frozen_string_literal: true

module Castle
  module Commands
    module Lists
      class Get
        class << self
          # @param options [Hash]
          # @return [Castle::Command]
          def build(options = {})
            Castle::Validators::Present.call(options, %i[list_id])

            Castle::Command.new("lists/#{options[:list_id]}", nil, :get)
          end
        end
      end
    end
  end
end

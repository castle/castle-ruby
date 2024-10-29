# frozen_string_literal: true

module Castle
  module Commands
    module ListItem
      class Count
        class << self
          # @param options [Hash]
          # @return [Castle::Command]
          def build(options = {})
            Castle::Validators::Present.call(options, %i[list_id])
            options[:filters]&.each { |f| Castle::Validators::Present.call(f, %i[field op value]) }

            list_id = options.delete(:list_id)

            Castle::Command.new("lists/#{list_id}/items/count", options, :post)
          end
        end
      end
    end
  end
end

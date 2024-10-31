# frozen_string_literal: true

module Castle
  module Commands
    module ListItems
      class Query
        class << self
          # @param options [Hash]
          # @return [Castle::Command]
          def build(options = {})
            Castle::Validators::Present.call(options, %i[list_id])
            options[:filters]&.each { |f| Castle::Validators::Present.call(f, %i[field op value]) }
            Castle::Validators::Present.call(options[:sort], %i[field order]) if options[:sort]

            list_id = options.delete(:list_id)

            Castle::Command.new("lists/#{list_id}/items/query", options, :post)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Castle
  module Commands
    module ListItem
      class Query
        class << self
          # @param options [Hash]
          # @return [Castle::Command]
          def build(options = {})
            Castle::Validators::Present.call(options, %i[list_id])
            options[:filters]&.each { |f| Castle::Validators::Present.call(f, %i[field op value]) }
            Castle::Validators::Present.call(options[:sort], %i[field order]) if options[:sort]

            Castle::Command.new("lists/#{options[:list_id]}/items/query", options, :post)
          end
        end
      end
    end
  end
end
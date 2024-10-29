# frozen_string_literal: true

module Castle
  module Commands
    module List
      class Query
        class << self
          # @param options [Hash]
          # @return [Castle::Command]
          def build(options = {})
            # Castle::Validators::Allowed.call(options, %i[filters page results_size include_size_label sort])
            options[:filters]&.each { |f| Castle::Validators::Present.call(f, %i[field op value]) }
            Castle::Validators::Present.call(options[:sort], %i[field order]) if options[:sort]

            Castle::Command.new("lists/query", options, :post)
          end
        end
      end
    end
  end
end

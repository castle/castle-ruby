# frozen_string_literal: true

module Castle
  module Commands
    module Events
      # Builds the command to query aggregated events
      class Group
        class << self
          # @param options [Hash]
          # @return [Castle::Command]
          def build(options = {})
            options[:filters]&.each { |f| Castle::Validators::Present.call(f, %i[field op value]) }
            Castle::Validators::Present.call(options[:sort], %i[field order]) if options[:sort]

            Castle::Command.new('events/group', options, :post)
          end
        end
      end
    end
  end
end

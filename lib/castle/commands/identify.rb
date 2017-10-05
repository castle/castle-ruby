# frozen_string_literal: true

module Castle
  module Commands
    class Identify
      include WithContext

      def build(options = {})
        validate!(options)
        build_context!(options)

        Castle::Command.new('identify', options, :post)
      end

      private

      def validate!(options)
        %i[user_id].each do |key|
          next unless options[key].to_s.empty?
          raise Castle::InvalidParametersError, "#{key} is missing or empty"
        end

        # check for properties
      end
    end
  end
end

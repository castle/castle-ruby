# frozen_string_literal: true

module Castle
  module Commands
    class Authenticate
      include WithContext

      def build(options = {})
        validate!(options)
        build_context!(options)

        Castle::Command.new('authenticate', options, :post)
      end

      private

      def validate!(options)
        %i[event user_id].each do |key|
          next unless options[key].to_s.empty?
          raise Castle::InvalidParametersError, "#{key} is missing or empty"
        end
      end
    end
  end
end

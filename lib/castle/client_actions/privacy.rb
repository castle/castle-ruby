# frozen_string_literal: true

module Castle
  module ClientActions
    # Client actions for the Privacy API (GDPR Articles 15 & 17).
    module Privacy
      # Triggers a "right of access" data export.
      # @param options [Hash] must include :identifier and :identifier_type ($id or $email)
      def request_user_data(options = {})
        Castle::API::Privacy::RequestData.call(options)
      end

      # Triggers a "right to be forgotten" data purge.
      # @param options [Hash] must include :identifier and :identifier_type ($id or $email)
      def delete_user_data(options = {})
        Castle::API::Privacy::DeleteData.call(options)
      end
    end
  end
end

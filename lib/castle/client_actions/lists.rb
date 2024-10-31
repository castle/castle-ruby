# frozen_string_literal: true

module Castle
  # Namespace for client actions
  module ClientActions
    # Client actions for lists
    module Lists
      # @param options [Hash]
      def create_list(options = {})
        Castle::API::Lists::Create.call(options)
      end

      # @param options [Hash]
      def delete_list(options = {})
        Castle::API::Lists::Delete.call(options)
      end

      # @param options [Hash]
      def get_all_lists(options = {})
        Castle::API::Lists::GetAll.call(options)
      end

      # @param options [Hash]
      def get_list(options = {})
        Castle::API::Lists::Get.call(options)
      end

      # @param options [Hash]
      def query_lists(options = {})
        Castle::API::Lists::Query.call(options)
      end

      # @param options [Hash]
      def update_list(options = {})
        Castle::API::Lists::Update.call(options)
      end
    end
  end
end

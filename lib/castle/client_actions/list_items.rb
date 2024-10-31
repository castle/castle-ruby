# frozen_string_literal: true

module Castle
  # Namesapce for client actions
  module ClientActions
    # Client actions for list items
    module ListItems
      # @param options [Hash]
      def archive_list_item(options = {})
        Castle::API::ListItems::Archive.call(options)
      end

      # @param options [Hash]
      def count_list_items(options = {})
        Castle::API::ListItems::Count.call(options)
      end

      # @param options [Hash]
      def create_list_item(options = {})
        Castle::API::ListItems::Create.call(options)
      end

      # @param options [Hash]
      def get_list_item(options = {})
        Castle::API::ListItems::Get.call(options)
      end

      # @param options [Hash]
      def query_list_items(options = {})
        Castle::API::ListItems::Query.call(options)
      end

      # @param options [Hash]
      def unarchive_list_item(options)
        Castle::API::ListItems::Unarchive.call(options)
      end

      # @param options [Hash]
      def update_list_item(options = {})
        Castle::API::ListItems::Update.call(options)
      end
    end
  end
end

# frozen_string_literal: true
module Castle
  module ClientActions
    module ListItems
      def archive_list_item(options)
        Castle::API::ListItems::Archive.call(options)
      end

      def count_list_items(options)
        Castle::API::ListItems::Count.call(options)
      end

      def create_list_item(options)
        Castle::API::ListItems::Create.call(options)
      end

      def get_list_item(options)
        Castle::API::ListItems::Get.call(options)
      end

      def query_list_items(options)
        Castle::API::ListItems::Query.call(options)
      end

      def unarchive_list_item(options)
        Castle::API::ListItems::Unarchive.call(options)
      end

      def update_list_item(options)
        Castle::API::ListItems::Update.call(options)
      end
    end
  end
end

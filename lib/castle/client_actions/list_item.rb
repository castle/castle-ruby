# frozen_string_literal: true
module Castle
  module ClientActions
    module ListItem
      def create_list(options)
        Castle::API::ListItem::Create.call(options)
      end

      def update_list(options)
        Castle::API::ListItem::Update.call(options)
      end

      def delete_list(options)
        Castle::API::ListItem::Delete.call(options)
      end

      def all_lists(options)
        Castle::API::ListItem::All.call(options)
      end

      def get_list(options)
        Castle::API::ListItem::Get.call(options)
      end

      def query_lists(options)
        Castle::API::ListItem::Query.call(options)
      end
    end
  end
end

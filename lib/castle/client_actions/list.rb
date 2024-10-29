# frozen_string_literal: true
module Castle
  module ClientActions
    module List
      def create_list(options)
        Castle::API::List::Create.call(options)
      end

      def update_list(options)
        Castle::API::List::Update.call(options)
      end

      def delete_list(options)
        Castle::API::List::Delete.call(options)
      end

      def all_lists(options)
        Castle::API::List::All.call(options)
      end

      def get_list(options)
        Castle::API::List::Get.call(options)
      end

      def query_lists(options)
        Castle::API::List::Query.call(options)
      end
    end
  end
end

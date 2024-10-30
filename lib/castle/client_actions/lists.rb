# frozen_string_literal: true
module Castle
  module ClientActions
    module Lists
      def create_list(options)
        Castle::API::Lists::Create.call(options)
      end

      def delete_list(options)
        Castle::API::Lists::Delete.call(options)
      end

      def get_all_lists
        Castle::API::Lists::GetAll.call
      end

      def get_list(options)
        Castle::API::Lists::Get.call(options)
      end

      def query_lists(options)
        Castle::API::Lists::Query.call(options)
      end

      def update_list(options)
        Castle::API::Lists::Update.call(options)
      end
    end
  end
end

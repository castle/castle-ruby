# frozen_string_literal: true
RSpec.shared_examples 'it has list actions' do
  describe 'all_lists' do
    it do
      client.all_lists
      assert_requested :get, 'https://api.castle.io/v1/lists', times: 1
    end
  end

  describe 'create_list' do
    it do
      client.create_list(name: 'list name', color: '$green', primary_field: 'user.email')
      assert_requested :post, 'https://api.castle.io/v1/lists', times: 1
    end
  end

  describe 'delete_list' do
    it do
      client.delete_list(list_id: 'list_id')
      assert_requested :delete, 'https://api.castle.io/v1/lists/list_id', times: 1
    end
  end

  describe 'get_list' do
    it do
      client.get_list(list_id: 'list_id')
      assert_requested :get, 'https://api.castle.io/v1/lists/list_id', times: 1
    end
  end

  describe 'query_lists' do
    it do
      client.query_lists(filters: [{ field: 'user.email', op: 'eq', value: 'test' }])
      assert_requested :post, 'https://api.castle.io/v1/lists/query', times: 1
    end
  end

  describe 'update_list' do
    it do
      client.update_list(list_id: 'list_id', name: 'list name', color: '$green', primary_field: 'user.email')
      assert_requested :put, 'https://api.castle.io/v1/lists/list_id', times: 1
    end
  end
end

# frozen_string_literal: true

RSpec.shared_examples 'it has list item actions' do
  describe 'archive_list_item' do
    it do
      client.archive_list_item(list_id: '1234', list_item_id: '5678')
      assert_requested :delete, 'https://api.castle.io/v1/lists/1234/items/5678/archive', times: 1
    end
  end

  describe 'count_list_items' do
    it do
      client.count_list_items(list_id: '1234', filters: [{ field: 'email', op: 'eq', value: 'test' }])
      assert_requested :post, 'https://api.castle.io/v1/lists/1234/items/count', times: 1
    end
  end

  describe 'create_list_item' do
    it do
      client.create_list_item(list_id: '1234', author: { type: 'other', identifier: '1234' }, primary_value: 'email')
      assert_requested :post, 'https://api.castle.io/v1/lists/1234/items', times: 1
    end
  end

  describe 'get_list_item' do
    it do
      client.get_list_item(list_id: '1234', list_item_id: '5678')
      assert_requested :get, 'https://api.castle.io/v1/lists/1234/items/5678', times: 1
    end
  end

  describe 'query_list_items' do
    it do
      client.query_list_items(list_id: '1234', filters: [{ field: 'email', op: 'eq', value: 'test' }])
      assert_requested :post, 'https://api.castle.io/v1/lists/1234/items/query', times: 1
    end
  end

  describe 'unarchive_list_item' do
    it do
      client.unarchive_list_item(list_id: '1234', list_item_id: '5678')
      assert_requested :put, 'https://api.castle.io/v1/lists/1234/items/5678/unarchive', times: 1
    end
  end

  describe 'update_list_item' do
    it do
      client.update_list_item(list_id: '1234', list_item_id: '5678', comment: 'updating comment')
      assert_requested :put, 'https://api.castle.io/v1/lists/1234/items/5678', times: 1
    end
  end
end

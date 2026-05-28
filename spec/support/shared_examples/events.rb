# frozen_string_literal: true

RSpec.shared_examples 'it has event actions' do
  describe 'events_schema' do
    it do
      client.events_schema
      assert_requested :get, 'https://api.castle.io/v1/events/schema', times: 1
    end
  end

  describe 'query_events' do
    it do
      client.query_events(filters: [{ field: 'user.id', op: '$eq', value: 'u-42' }], query_type: '$records')
      assert_requested :post, 'https://api.castle.io/v1/events/query', times: 1
    end
  end

  describe 'group_events' do
    it do
      client.group_events(filters: [{ field: 'user.id', op: '$eq', value: 'u-42' }])
      assert_requested :post, 'https://api.castle.io/v1/events/group', times: 1
    end
  end
end

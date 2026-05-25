# frozen_string_literal: true

RSpec.shared_examples 'it has privacy actions' do
  describe 'request_user_data' do
    it do
      client.request_user_data(identifier: 'rhea@example.org', identifier_type: '$email')
      assert_requested :post, 'https://api.castle.io/v1/privacy/users', times: 1
    end
  end

  describe 'delete_user_data' do
    it do
      client.delete_user_data(identifier: 'user_42', identifier_type: '$id')
      assert_requested :delete, 'https://api.castle.io/v1/privacy/users', times: 1
    end
  end
end

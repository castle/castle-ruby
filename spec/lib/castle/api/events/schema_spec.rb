# frozen_string_literal: true

RSpec.describe Castle::API::Events::Schema do
  before do
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(status: 200, body: '[]', headers: {})
  end

  describe '.call' do
    subject(:call) { described_class.call }

    before { call }

    it do
      assert_requested :get, 'https://api.castle.io/v1/events/schema', times: 1
    end
  end
end

# frozen_string_literal: true

RSpec.describe Castle::API::Events::Query do
  before do
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(status: 200, body: '{}', headers: {})
  end

  describe '.call' do
    subject(:call) { described_class.call(options) }

    let(:options) { { filters: [{ field: 'user.id', op: '$eq', value: 'u-42' }], query_type: '$records' } }

    before { call }

    it do
      assert_requested :post, 'https://api.castle.io/v1/events/query', times: 1 do |req|
        expect(JSON.parse(req.body, symbolize_names: true)).to eq(options)
      end
    end
  end
end

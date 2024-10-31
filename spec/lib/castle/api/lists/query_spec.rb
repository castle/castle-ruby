# frozen_string_literal: true

describe Castle::API::Lists::Query do
  before do
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(status: 200, body: '{}', headers: {})
  end

  describe '.call' do
    subject(:all) { described_class.call(options) }

    let(:options) { { filters: [{ field: 'test', op: '$eq', value: 'test' }] } }

    before { all }

    it do
      assert_requested :post, "https://api.castle.io/v1/lists/query", times: 1 do |req|
        expect(JSON.parse(req.body, symbolize_names: true)).to eq(options)
      end
    end
  end
end

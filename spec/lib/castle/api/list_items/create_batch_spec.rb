# frozen_string_literal: true

RSpec.describe Castle::API::ListItems::CreateBatch do
  before do
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(status: 200, body: '{}', headers: {})
  end

  describe '.call' do
    subject(:call) { described_class.call(options) }

    let(:items) { [{ primary_value: 'a' }, { primary_value: 'b' }] }
    let(:options) { { list_id: '123', items: items } }

    before { call }

    it do
      assert_requested :post, "https://api.castle.io/v1/lists/#{options[:list_id]}/items/batch", times: 1 do |req|
        expect(JSON.parse(req.body, symbolize_names: true)).to eq(items: items)
      end
    end
  end
end

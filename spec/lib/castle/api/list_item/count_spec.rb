# frozen_string_literal: true

describe Castle::API::ListItem::Count do
  before do
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(status: 200, body: '{}', headers: {})
  end

  describe '.call' do
    subject(:all) { described_class.call(options) }

    let(:options) { { list_id: '123', filters: [{ field: 'test', op: '$eq', value: 'test' }] } }


    before { all }

    it do
      assert_requested :post, "https://api.castle.io/v1/lists/#{options[:list_id]}/items/count", times: 1 do |req|
        expect(JSON.parse(req.body, symbolize_names: true)).to eq(options.except(:list_id))
      end
    end
  end
end

# frozen_string_literal: true

describe Castle::API::ListItems::Create do
  before do
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(status: 200, body: '{}', headers: {})
  end

  describe '.call' do
    subject(:all) { described_class.call(options) }

    let(:author) { { type: '$other', identifier: 'test identifier' } }
    let(:options) { { list_id: '123', primary_value: 'test value', author: author,  } }

    before { all }

    it do
      assert_requested :post, "https://api.castle.io/v1/lists/#{options[:list_id]}/items", times: 1 do |req|
        expect(JSON.parse(req.body, symbolize_names: true)).to eq(options.except(:list_id))
      end
    end
  end
end

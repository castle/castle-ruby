# frozen_string_literal: true

describe Castle::API::List::Create do
  before do
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(status: 200, body: '{}', headers: {})
  end

  describe '.call' do
    subject(:all) { described_class.call(options) }

    let(:options) { { name: 'name', color: '$red', primary_field: 'user.email' } }


    before { all }

    it do
      assert_requested :post, 'https://api.castle.io/v1/lists', times: 1 do |req|
        expect(JSON.parse(req.body, symbolize_names: true)).to eq(options)
      end
    end
  end
end

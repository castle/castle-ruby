# frozen_string_literal: true

describe Castle::API::List::Update do
  before do
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(status: 200, body: '{}', headers: {})
  end

  describe '.call' do
    subject(:all) { described_class.call(options) }

    let(:options) { { list_id: '123', name: 'name', color: '$red' } }


    before { all }

    it do
      assert_requested :put, "https://api.castle.io/v1/lists/#{options[:list_id]}", times: 1 do |req|
        expect(JSON.parse(req.body, symbolize_names: true)).to eq(options.except(:list_id))
      end
    end
  end
end

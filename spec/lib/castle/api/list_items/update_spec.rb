# frozen_string_literal: true

describe Castle::API::ListItems::Update do
  before do
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(status: 200, body: '{}', headers: {})
  end

  describe '.call' do
    let(:url) { "https://api.castle.io/v1/lists/#{options[:list_id]}/items/#{options[:list_item_id]}" }
    let(:options) { { list_id: '123', list_item_id: '456', comment: 'updating comment!' } }
    subject(:all) { described_class.call(options) }

    before { all }

    it do
      assert_requested :put, url, times: 1 do |req|
        expect(JSON.parse(req.body, symbolize_names: true)).to eq(options.except(:list_id, :list_item_id))
      end
    end
  end
end

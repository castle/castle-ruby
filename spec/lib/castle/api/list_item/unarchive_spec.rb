# frozen_string_literal: true

describe Castle::API::ListItem::Unarchive do
  before do
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(status: 200, body: '{}', headers: {})
  end

  describe '.call' do
    subject(:all) { described_class.call(options) }

    let(:url) { "https://api.castle.io/v1/lists/#{options[:list_id]}/items/#{options[:list_item_id]}/unarchive" }
    let(:options) { { list_id: '123', list_item_id: '456' } }

    before { all }

    it { assert_requested :put, url, times: 1 }
  end
end

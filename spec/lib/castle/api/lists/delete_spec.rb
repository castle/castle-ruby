# frozen_string_literal: true

describe Castle::API::Lists::Delete do
  before do
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(status: 200, body: '{}', headers: {})
  end

  describe '.call' do
    subject(:all) { described_class.call(options) }

    let(:options) { { list_id: '123' } }

    before { all }

    it { assert_requested :delete, "https://api.castle.io/v1/lists/#{options[:list_id]}", times: 1 }
  end
end

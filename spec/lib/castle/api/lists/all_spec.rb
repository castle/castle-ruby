# frozen_string_literal: true

describe Castle::API::Lists::All do
  before do
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(status: 200, body: '{}', headers: {})
  end

  describe '.call' do
    subject(:all) { described_class.call(options) }

    let(:options) { { } }


    before { all }

    it { assert_requested :get, "https://api.castle.io/v1/lists", times: 1 }
  end
end

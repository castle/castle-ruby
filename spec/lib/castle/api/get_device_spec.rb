# frozen_string_literal: true

describe Castle::API::GetDevice do
  before do
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(status: 200, body: '{}', headers: {})
  end

  describe '.call' do
    subject(:retrieve) { described_class.call(device_token: device_token) }

    let(:device_token) { '1234' }

    before { retrieve }

    it { assert_requested :get, "https://api.castle.io/v1/devices/#{device_token}", times: 1 }
  end
end

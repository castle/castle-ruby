# frozen_string_literal: true

RSpec.describe Castle::API::ReportDevice do
  before do
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(status: 200, body: '{}', headers: {})
  end

  describe '.call' do
    subject(:retrieve) { described_class.call(device_token: device_token) }

    let(:device_token) { '1234' }

    before { retrieve }

    it { assert_requested :put, "https://api.castle.io/v1/devices/#{device_token}/report", times: 1 }
  end
end

# frozen_string_literal: true

describe Castle::API::GetDevicesForUser do
  before do
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(status: 200, body: '{}', headers: {})
  end

  describe '.call' do
    subject(:retrieve) { described_class.call(user_id: user_id) }

    let(:user_id) { '1234' }

    before { retrieve }

    it { assert_requested :get, "https://api.castle.io/v1/users/#{user_id}/devices", times: 1 }
  end
end

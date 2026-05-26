# frozen_string_literal: true

RSpec.describe Castle::API::Privacy::DeleteData do
  before do
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(status: 202, body: '', headers: {})
  end

  describe '.call' do
    subject(:call) { described_class.call(options) }

    let(:options) { { identifier: 'user_42', identifier_type: '$id' } }

    before { call }

    it 'DELETEs /v1/privacy/users with the provided identifier payload' do
      assert_requested :delete, 'https://api.castle.io/v1/privacy/users', times: 1 do |req|
        expect(JSON.parse(req.body, symbolize_names: true)).to eq(options)
      end
    end
  end
end

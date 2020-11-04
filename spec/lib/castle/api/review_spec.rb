# frozen_string_literal: true

describe Castle::API::Review do
  before do
    stub_request(:any, /api.castle.io/).with(
      basic_auth: ['', 'secret']
    ).to_return(status: 200, body: '{}', headers: {})
  end

  describe '.call' do
    subject(:retrieve) { described_class.call(review_id) }

    let(:review_id) { '1234' }

    before { retrieve }

    it { assert_requested :get, "https://api.castle.io/v1/reviews/#{review_id}", times: 1 }
  end
end

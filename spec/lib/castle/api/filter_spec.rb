# frozen_string_literal: true

RSpec.describe Castle::API::Filter do
  describe '.call' do
    let(:options) { { type: '$login', status: '$attempted', request_token: 'token', params: { email: 'foo@bar.com' } } }

    context 'when the request fails and the failover strategy is not :throw' do
      before do
        allow(Castle::API).to receive(:send_request).and_raise(Castle::RequestError.new(Timeout::Error))
        allow(Castle.config).to receive(:failover_strategy).and_return(:allow)
      end

      it 'does not crash when options have no :user node (regression: #279)' do
        expect { described_class.call(options) }.not_to raise_error
      end

      it 'returns a failover response with nil user_id' do
        response = described_class.call(options)
        expect(response[:user_id]).to be_nil
        expect(response[:failover]).to be true
      end

      it 'falls back to matching_user_id when present' do
        response = described_class.call(options.merge(matching_user_id: 'mu-123'))
        expect(response[:user_id]).to eq('mu-123')
      end

      it 'still uses user.id when present' do
        response = described_class.call(options.merge(user: { id: '42' }))
        expect(response[:user_id]).to eq('42')
      end
    end
  end
end

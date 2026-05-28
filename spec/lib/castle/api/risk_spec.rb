# frozen_string_literal: true

RSpec.describe Castle::API::Risk do
  describe '.call' do
    let(:options) do
      { type: '$login', status: '$succeeded', request_token: 'token', user: { id: 'u-42' }, context: { ip: '1.2.3.4' } }
    end

    context 'when the request succeeds' do
      before do
        stub_request(:post, 'https://api.castle.io/v1/risk').to_return(
          status: 201,
          body: { policy: { action: 'allow' } }.to_json,
          headers: {
            'Content-Type' => 'application/json'
          }
        )
      end

      it 'returns the parsed verdict with failover metadata' do
        response = described_class.call(options)
        expect(response[:policy][:action]).to eq('allow')
        expect(response[:failover]).to be false
        expect(response[:failover_reason]).to be_nil
      end
    end

    context 'when the request fails and the failover strategy is not :throw' do
      before do
        allow(Castle::API).to receive(:send_request).and_raise(Castle::RequestError.new(Timeout::Error))
        allow(Castle.config).to receive(:failover_strategy).and_return(:allow)
      end

      it 'returns a failover response with the supplied user.id' do
        response = described_class.call(options)
        expect(response[:user_id]).to eq('u-42')
        expect(response[:failover]).to be true
      end

      it 'does not crash when :user is missing (regression: #279)' do
        expect { described_class.call(options.merge(user: {})) }.not_to raise_error
      end
    end

    context 'when the failover strategy is :throw' do
      before do
        allow(Castle::API).to receive(:send_request).and_raise(Castle::RequestError.new(Timeout::Error))
        allow(Castle.config).to receive(:failover_strategy).and_return(:throw)
      end

      it 're-raises the underlying RequestError' do
        expect { described_class.call(options) }.to raise_error(Castle::RequestError)
      end
    end
  end
end

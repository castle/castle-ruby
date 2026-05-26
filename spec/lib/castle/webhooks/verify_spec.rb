# frozen_string_literal: true

RSpec.describe Castle::Webhooks::Verify do
  describe '#call' do
    subject(:call) { described_class.call(webhook) }

    let(:env) { Rack::MockRequest.env_for('/', 'HTTP_X_CASTLE_SIGNATURE' => signature) }

    let(:webhook) { Rack::Request.new(env) }
    let(:user_id) { '12345' }
    let(:webhook_body) do
      {
        api_version: 'v1',
        app_id: '12345',
        type: '$incident.confirmed',
        created_at: '2020-12-18T12:55:21.779Z',
        data: {
          id: 'test',
          device_token: 'token',
          user_id: user_id,
          trigger: '$login.succeeded',
          context: {
          },
          location: {
          },
          user_agent: {
          }
        },
        user_traits: {
        },
        properties: {
        },
        policy: {
        }
      }.to_json
    end

    context 'when success' do
      let(:signature) { '3ptx3rUOBnGEqPjMrbcJn2UUfzwTKP54dFyP5uyPY+Y=' }

      before { allow(Castle::Core::ProcessWebhook).to receive(:call).and_return(webhook_body) }

      it { expect { call }.not_to raise_error }
    end

    context 'when signature is malformed' do
      let(:signature) { '123' }

      before { allow(Castle::Core::ProcessWebhook).to receive(:call).and_return(webhook_body) }

      it do
        expect { call }.to raise_error(
          Castle::WebhookVerificationError,
          'Signature not matching the expected signature'
        )
      end
    end
  end
end

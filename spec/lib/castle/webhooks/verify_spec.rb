# frozen_string_literal: true

describe Castle::Webhooks::Verify do
  describe '#call' do
    subject(:call) { described_class.call(webhook) }

    let(:env) do
      Rack::MockRequest.env_for(
        '/',
        'X-CASTLE-SIGNATURE' => signature
      )
    end
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
          context: {},
          location: {},
          user_agent: {}
        },
        user_traits: {},
        properties: {},
        policy: {}
      }
    end

    context 'when success' do
      let(:signature) { '+Ix+vkdA21nIc87PXh8Y43JqGtZAaKE9dkt5AoQwqw4=' }

      before do
        allow(Castle::Core::ProcessWebhook)
          .to receive(:call)
          .and_return(webhook_body)
      end

      it { expect { call }.not_to raise_error }
    end

    context 'when user_id empty' do
      let(:user_id) { nil }
      let(:signature) { '+eZuF5tnR65UEI+C+K3os8Jddv0wr95sOVgixTAZYWk=' }

      before do
        allow(Castle::Core::ProcessWebhook)
          .to receive(:call)
          .and_return(webhook_body)
      end

      it { expect { call }.not_to raise_error }
    end

    context 'when signature is malformed' do
      let(:signature) { '123' }

      before do
        allow(Castle::Core::ProcessWebhook)
          .to receive(:call)
          .and_return(webhook_body)
      end

      it do
        expect { call }
          .to raise_error(
            Castle::WebhookVerificationError,
            'Signature not matching the expected signature'
          )
      end
    end
  end
end

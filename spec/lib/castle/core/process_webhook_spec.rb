# frozen_string_literal: true

describe Castle::Core::ProcessWebhook do
  describe '#call' do
    subject(:call) { described_class.call(webhook) }

    let(:webhook_body) do
      {
        api_version: 'v1',
        app_id: '12345',
        type: '$incident.confirmed',
        created_at: '2020-12-18T12:55:21.779Z',
        data: {
          id: 'test',
          device_token: 'token',
          user_id: '',
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

    let(:webhook) { OpenStruct.new(body: StringIO.new(webhook_body)) }

    context 'when success' do
      it { expect(call).to eql(webhook_body) }
    end

    context 'when webhook empty' do
      let(:webhook) { OpenStruct.new(body: StringIO.new('')) }

      it { expect { call }.to raise_error(Castle::ApiError, 'Invalid webhook from Castle API') }
    end

    context 'when webhook nil' do
      let(:webhook) { OpenStruct.new(body: StringIO.new) }

      it { expect { call }.to raise_error(Castle::ApiError, 'Invalid webhook from Castle API') }
    end
  end
end

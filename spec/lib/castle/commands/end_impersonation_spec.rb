# frozen_string_literal: true

describe Castle::Commands::EndImpersonation do
  subject(:instance) { described_class }

  let(:context) { { user_agent: 'test', ip: '127.0.0.1', client_id: 'test' } }
  let(:impersonator) { 'test@castle.io' }
  let(:default_payload) do
    { user_id: '1234', sent_at: time_auto, context: context }
  end

  let(:time_now) { Time.now }
  let(:time_auto) { time_now.utc.iso8601(3) }

  before { Timecop.freeze(time_now) }

  after { Timecop.return }

  describe '.build' do
    subject(:command) { instance.build(payload) }

    context 'with impersonator' do
      let(:payload) do
        default_payload.merge(properties: { impersonator: impersonator })
      end
      let(:command_data) do
        default_payload.merge(
          properties: {
            impersonator: impersonator
          },
          context: context
        )
      end

      it { expect(command.method).to be_eql(:delete) }
      it { expect(command.path).to be_eql('impersonate') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'when active true' do
      let(:payload) do
        default_payload.merge(context: context.merge(active: true))
      end
      let(:command_data) do
        default_payload.merge(context: context.merge(active: true))
      end

      it { expect(command.method).to be_eql(:delete) }
      it { expect(command.path).to be_eql('impersonate') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'when active false' do
      let(:payload) do
        default_payload.merge(context: context.merge(active: false))
      end
      let(:command_data) do
        default_payload.merge(context: context.merge(active: false))
      end

      it { expect(command.method).to be_eql(:delete) }
      it { expect(command.path).to be_eql('impersonate') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'when active string' do
      let(:payload) do
        default_payload.merge(context: context.merge(active: 'string'))
      end
      let(:command_data) { default_payload.merge(context: context) }

      it { expect(command.method).to be_eql(:delete) }
      it { expect(command.path).to be_eql('impersonate') }
      it { expect(command.data).to be_eql(command_data) }
    end
  end

  describe '#validate!' do
    subject(:validate!) { instance.build(payload) }

    context 'when user_id not present' do
      let(:payload) { {} }

      it do
        expect { validate! }.to raise_error(
          Castle::InvalidParametersError,
          'user_id is missing or empty'
        )
      end
    end

    context 'when user_id present' do
      let(:payload) { { user_id: '1234', context: context } }

      it { expect { validate! }.not_to raise_error }
    end
  end
end

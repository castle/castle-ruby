# frozen_string_literal: true

describe Castle::Commands::Impersonate do
  subject(:instance) { described_class.new(context) }

  let(:context) { { user_agent: 'test', ip: '127.0.0.1', client_id: 'test' } }
  let(:impersonator) { 'test@castle.io' }
  let(:default_payload) { { user_id: '1234', sent_at: time_auto } }

  let(:time_now) { Time.now }
  let(:time_auto) { time_now.utc.iso8601(3) }

  before { Timecop.freeze(time_now) }

  after { Timecop.return }

  describe '.build' do
    subject(:command) { instance.build(payload) }

    context 'with simple merger' do
      let(:payload) { default_payload.merge(context: { test: { test2: '1' } }) }
      let(:command_data) do
        default_payload.merge(
          context: {
            test: { test2: '1' },
            user_agent: 'test',
            ip: '127.0.0.1',
            client_id: 'test'
          }
        )
      end

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('impersonate') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'with impersonator' do
      let(:payload) { default_payload.merge(impersonator: impersonator) }
      let(:command_data) do
        default_payload.merge(impersonator: impersonator, context: context)
      end

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('impersonate') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'when active true' do
      let(:payload) { default_payload.merge(context: { active: true }) }
      let(:command_data) do
        default_payload.merge(context: context.merge(active: true))
      end

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('impersonate') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'when active false' do
      let(:payload) { default_payload.merge(context: { active: false }) }
      let(:command_data) do
        default_payload.merge(context: context.merge(active: false))
      end

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('impersonate') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'when active string' do
      let(:payload) { default_payload.merge(context: { active: 'string' }) }
      let(:command_data) { default_payload.merge(context: context) }

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('impersonate') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'when reset' do
      let(:payload) { default_payload.merge(reset: true) }

      it { expect(command.method).to be_eql(:delete) }
      it { expect(command.path).to be_eql('impersonate') }
    end
  end

  describe '#validate!' do
    subject(:validate!) { instance.build(payload) }

    context 'when user_id not present' do
      let(:payload) { {} }

      it do
        expect do
          validate!
        end.to raise_error(Castle::InvalidParametersError, 'user_id is missing or empty')
      end
    end

    context 'when user_id present' do
      let(:payload) { { user_id: '1234' } }

      it { expect { validate! }.not_to raise_error }
    end
  end
end

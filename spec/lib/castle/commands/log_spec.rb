# frozen_string_literal: true

describe Castle::Commands::Log do
  subject(:instance) { described_class }

  let(:context) { { test: { test1: '1' } } }
  let(:user) { { id: '1234', email: 'foobar@mail.com' } }
  let(:default_payload) do
    {
      request_token: '7e51335b-f4bc-4bc7-875d-b713fb61eb23-bf021a3022a1a302',
      event: '$login',
      status: '$failed',
      user: user,
      sent_at: time_auto,
      context: context
    }
  end
  let(:time_now) { Time.now }
  let(:time_auto) { time_now.utc.iso8601(3) }

  before { Timecop.freeze(time_now) }

  after { Timecop.return }

  describe '.build' do
    subject(:command) { instance.build(payload) }

    context 'with properties' do
      let(:payload) { default_payload.merge(properties: { test: '1' }) }
      let(:command_data) { default_payload.merge(properties: { test: '1' }, context: context) }

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('log') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'with user_traits' do
      let(:payload) { default_payload.merge(user_traits: { test: '1' }) }
      let(:command_data) { default_payload.merge(user_traits: { test: '1' }, context: context) }

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('log') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'when active true' do
      let(:payload) { default_payload.merge(context: context.merge(active: true)) }
      let(:command_data) { default_payload.merge(context: context.merge(active: true)) }

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('log') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'when active false' do
      let(:payload) { default_payload.merge(context: context.merge(active: false)) }
      let(:command_data) { default_payload.merge(context: context.merge(active: false)) }

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('log') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'when active string' do
      let(:payload) { default_payload.merge(context: context.merge(active: 'string')) }
      let(:command_data) { default_payload.merge(context: context) }

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('log') }
      it { expect(command.data).to be_eql(command_data) }
    end
  end

  describe '#validate!' do
    subject(:validate!) { instance.build(payload) }

    context 'with event not present' do
      let(:payload) { {} }

      it do
        expect { validate! }.to raise_error(
          Castle::InvalidParametersError,
          'event is missing or empty'
        )
      end
    end

    context 'with user not present' do
      let(:payload) { { event: '$login' } }

      it { expect { validate! }.not_to raise_error }
    end

    context 'with event and user present' do
      let(:payload) { { event: '$login', user: user } }

      it { expect { validate! }.not_to raise_error }
    end
  end
end

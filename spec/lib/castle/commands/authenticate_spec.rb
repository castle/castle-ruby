# frozen_string_literal: true

describe Castle::Commands::Authenticate do
  subject(:instance) { described_class }

  let(:context) { { test: { test1: '1' } } }
  let(:default_payload) do
    {
      event: '$login',
      user_id: '1234',
      ip: '127.0.0.1',
      fingerprint: 'test',
      headers: {
        'random' => 'header'
      },
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
      it { expect(command.path).to be_eql('authenticate') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'with user_traits' do
      let(:payload) { default_payload.merge(user_traits: { test: '1' }) }
      let(:command_data) { default_payload.merge(user_traits: { test: '1' }, context: context) }

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('authenticate') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'when active true' do
      let(:payload) { default_payload.merge(context: context.merge(active: true)) }
      let(:command_data) { default_payload.merge(context: context.merge(active: true)) }

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('authenticate') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'when active false' do
      let(:payload) { default_payload.merge(context: context.merge(active: false)) }
      let(:command_data) { default_payload.merge(context: context.merge(active: false)) }

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('authenticate') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'when active string' do
      let(:payload) { default_payload.merge(context: context.merge(active: 'string')) }
      let(:command_data) { default_payload.merge(context: context) }

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('authenticate') }
      it { expect(command.data).to be_eql(command_data) }
    end
  end

  describe '#validate!' do
    subject(:validate!) { instance.build(payload) }

    context 'with event not present' do
      let(:payload) do
        {
          user_id: '1234',
          ip: '127.0.0.1',
          fingerprint: 'test',
          headers: {
            'random' => 'header'
          }
        }
      end

      it do
        expect { validate! }.to raise_error(
          Castle::InvalidParametersError,
          'event is missing or empty'
        )
      end
    end

    context 'with user_id not present' do
      let(:payload) do
        {
          event: '$login',
          ip: '127.0.0.1',
          fingerprint: 'test',
          headers: {
            'random' => 'header'
          }
        }
      end

      it { expect { validate! }.not_to raise_error }
    end

    context 'with ip not present' do
      let(:payload) { { event: '$login', fingerprint: 'test', headers: { 'random' => 'header' } } }

      it do
        expect { validate! }.to raise_error(
          Castle::InvalidParametersError,
          'ip is missing or empty'
        )
      end
    end

    context 'with headers not present' do
      let(:payload) { { event: '$login', ip: '127.0.0.1', fingerprint: 'test' } }

      it do
        expect { validate! }.to raise_error(
          Castle::InvalidParametersError,
          'headers is missing or empty'
        )
      end
    end

    context 'with fingerprint not present' do
      let(:payload) do
        { event: '$login', user_id: '1234', ip: '127.0.0.1', headers: { 'random' => 'header' } }
      end

      it do
        expect { validate! }.to raise_error(
          Castle::InvalidParametersError,
          'fingerprint is missing or empty'
        )
      end
    end

    context 'with event, ip, headers and fingerprint present' do
      let(:payload) { default_payload }

      it { expect { validate! }.not_to raise_error }
    end
  end
end

# frozen_string_literal: true

describe Castle::Commands::Identify do
  subject(:instance) { described_class.new(context) }

  let(:context) { { test: { test1: '1' } } }
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
        default_payload.merge(context: { test: { test1: '1', test2: '1' } })
      end

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('identify') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'with user_traits' do
      let(:payload) { default_payload.merge(user_traits: { test: '1' }) }
      let(:command_data) do
        default_payload.merge(user_traits: { test: '1' }, context: context)
      end

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('identify') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'when active true' do
      let(:payload) { default_payload.merge(context: { active: true }) }
      let(:command_data) do
        default_payload.merge(context: context.merge(active: true))
      end

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('identify') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'when active false' do
      let(:payload) { default_payload.merge(context: { active: false }) }
      let(:command_data) do
        default_payload.merge(context: context.merge(active: false))
      end

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('identify') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'when active string' do
      let(:payload) { default_payload.merge(context: { active: 'string' }) }
      let(:command_data) { default_payload.merge(context: context) }

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('identify') }
      it { expect(command.data).to be_eql(command_data) }
    end
  end

  describe '#validate!' do
    subject(:validate!) { instance.build(payload) }

    context 'with user_id not present' do
      let(:payload) { {} }

      it { expect { validate! }.not_to raise_error }
    end

    context 'with user_id present' do
      let(:payload) { { user_id: '1234' } }

      it { expect { validate! }.not_to raise_error }
    end
  end
end

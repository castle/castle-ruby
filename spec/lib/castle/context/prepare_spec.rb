# frozen_string_literal: true

describe Castle::Context::Prepare do
  let(:context) { { active: true, library: { name: 'castle-rb', version: '6.0.0' } } }

  before { stub_const('Castle::VERSION', '6.0.0') }

  describe '#call' do
    subject(:generated) { described_class.call }

    context 'when active true' do
      it { is_expected.to eql(context) }
    end
  end
end

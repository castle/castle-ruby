# frozen_string_literal: true

describe Castle::ContextSanitizer do
  let(:paylod) { { test: 'test' } }

  describe '#call' do
    subject { described_class.call(context) }

    context 'when active true' do
      let(:context) { paylod.merge(active: true) }

      it { is_expected.to eql(context) }
    end

    context 'when active false' do
      let(:context) { paylod.merge(active: false) }

      it { is_expected.to eql(context) }
    end

    context 'when active string' do
      let(:context) { paylod.merge(active: 'uknown') }

      it { is_expected.to eql(paylod) }
    end
  end
end

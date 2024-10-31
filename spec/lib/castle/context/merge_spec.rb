# frozen_string_literal: true

RSpec.describe Castle::Context::Merge do
  let(:first) { { test: { test1: { c: '4' } } } }

  describe '#call' do
    subject { described_class.call(first, second) }

    let(:result) { { test: { test1: { c: '4', d: '5' } } } }

    context 'with symbol keys' do
      let(:second) { { test: { test1: { d: '5' } } } }

      it { is_expected.to eq(result) }
    end

    context 'with string keys' do
      let(:second) { { 'test' => { 'test1' => { 'd' => '5' } } } }

      it { is_expected.to eq(result) }
    end
  end
end

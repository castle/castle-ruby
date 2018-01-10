# frozen_string_literal: true

describe Castle::ContextMerger do
  let(:first) { { test: { test1: { c: '4' } } } }

  context '#call' do
    subject { described_class.call(first, second) }

    let(:result) { { test: { test1: { c: '4', d: '5' } } } }

    context 'symbol keys' do
      let(:second) { { test: { test1: { d: '5' } } } }

      it { is_expected.to eq(result) }
    end

    context 'string keys' do
      let(:second) { { 'test' => { 'test1' => { 'd' => '5' } } } }

      it { is_expected.to eq(result) }
    end
  end
end

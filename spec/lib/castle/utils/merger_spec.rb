# frozen_string_literal: true

describe Castle::Utils::Merger do
  subject(:merger) { described_class }

  describe 'call' do
    let(:first) { { test: { test1: { c: '4' }, test2: { c: '3' }, a: '1', b: '2' } } }
    let(:second) { { test2: '2', test: { 'test1' => { d: '5' }, test2: '6', a: nil, b: '3' } } }
    let(:result) { { test2: '2', test: { test1: { c: '4', d: '5' }, test2: '6', b: '3' } } }

    it { expect(merger.call(first, second)).to be_eql(result) }
  end
end

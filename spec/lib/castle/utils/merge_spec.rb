# frozen_string_literal: true

describe Castle::Utils::Merge do
  subject(:merge) { described_class }

  describe 'call' do
    let(:first) { { test: { test1: { c: '4' }, test2: { c: '3' }, a: '1', b: '2' } } }
    let(:second) do
      { test2: '2', test: { 'test1' => { d: '5' }, :test2 => '6', :a => nil, :b => '3' } }
    end
    let(:result) { { test2: '2', test: { test1: { c: '4', d: '5' }, test2: '6', b: '3' } } }

    it { expect(merge.call(first, second)).to be_eql(result) }
  end
end

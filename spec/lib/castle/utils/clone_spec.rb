# frozen_string_literal: true

describe Castle::Utils::Clone do
  subject(:clone) { described_class }

  describe 'call' do
    let(:nested) { { c: '3' } }
    let(:first) do
      { test: { test1: { c: '4' }, test2: nested, a: '1', b: '2' } }
    end
    let(:result) do
      { test: { test1: { c: '4' }, test2: { c: '3' }, a: '1', b: '2' } }
    end
    let(:cloned) { clone.call(first) }

    before { cloned }

    it do
      nested[:test] = 'sample'
      expect(cloned).to be_eql(result)
    end
  end
end

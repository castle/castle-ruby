# frozen_string_literal: true

require 'spec_helper'

describe Castle::Utils::Cloner do
  subject(:cloner) { described_class }

  describe 'call' do
    let(:nested) { { c: '3' } }
    let(:first) { { test: { test1: { c: '4' }, test2: nested, a: '1', b: '2' } } }
    let(:result) { { test: { test1: { c: '4' }, test2: { c: '3' }, a: '1', b: '2' } } }
    let(:cloned) { cloner.call(first) }

    before { cloned }
    it do
      nested[:test] = 'sample'
      expect(cloned).to be_eql(result)
    end
  end
end

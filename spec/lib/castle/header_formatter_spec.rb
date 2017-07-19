# frozen_string_literal: true

require 'spec_helper'

describe Castle::HeaderFormatter do
  subject do
    described_class.new
  end

  it 'removes HTTP_' do
    expect(subject.call('HTTP_X_TEST')).to be_eql('X-Test')
  end

  it 'capitalizes header' do
    expect(subject.call('X_TEST')).to be_eql('X-Test')
  end

  it 'ignores letter case and -_ divider' do
    expect(subject.call('http-X_teST')).to be_eql('X-Test')
  end

  it 'does not remove http if there is no _- char' do
    expect(subject.call('httpX_teST')).to be_eql('Httpx-Test')
  end
end

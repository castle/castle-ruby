# frozen_string_literal: true

describe Castle::HeaderFormatter do
  subject(:formatter) { described_class.new }

  it 'removes HTTP_' do
    expect(formatter.call('HTTP_X_TEST')).to be_eql('X-Test')
  end

  it 'capitalizes header' do
    expect(formatter.call('X_TEST')).to be_eql('X-Test')
  end

  it 'ignores letter case and -_ divider' do
    expect(formatter.call('http-X_teST')).to be_eql('X-Test')
  end

  it 'does not remove http if there is no _- char' do
    expect(formatter.call('httpX_teST')).to be_eql('Httpx-Test')
  end

  it 'capitalizes' do
    expect(formatter.call(:clearance)).to be_eql('Clearance')
  end
end

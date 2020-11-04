# frozen_string_literal: true

describe Castle::Headers::Format do
  subject(:format) { described_class }

  it 'removes HTTP_' do
    expect(format.call('HTTP_X_TEST')).to be_eql('X-Test')
  end

  it 'capitalizes header' do
    expect(format.call('X_TEST')).to be_eql('X-Test')
  end

  it 'ignores letter case and -_ divider' do
    expect(format.call('http-X_teST')).to be_eql('X-Test')
  end

  it 'does not remove http if there is no _- char' do
    expect(format.call('httpX_teST')).to be_eql('Httpx-Test')
  end

  it 'capitalizes' do
    expect(format.call(:clearance)).to be_eql('Clearance')
  end
end

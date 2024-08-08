# frozen_string_literal: true

describe Castle::Headers::Format do
  subject(:format) { described_class }

  it 'removes HTTP_' do
    expect(format.call('HTTP_X_TEST')).to eql('X-Test')
  end

  it 'capitalizes header' do
    expect(format.call('X_TEST')).to eql('X-Test')
  end

  it 'ignores letter case and -_ divider' do
    expect(format.call('http-X_teST')).to eql('X-Test')
  end

  it 'does not remove http if there is no _- char' do
    expect(format.call('httpX_teST')).to eql('Httpx-Test')
  end

  it 'capitalizes' do
    expect(format.call(:clearance)).to eql('Clearance')
  end
end

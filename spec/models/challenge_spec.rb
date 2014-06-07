require 'spec_helper'

describe 'Userbin::Challenge' do
  it 'creates a challenge' do
    VCR.use_cassette('challenge_create') do
      challenge = Userbin::Challenge.post(
        "users/dTxR68nzuRXT4wrB2HJ4hanYtcaGSz2y/challenges")
      challenge.channel.token.id.should == 'VVG3qirUxy8mUSkmzy3QpPcuhLN1JY4r'
    end
  end

  it 'verifies a challenge' do
    VCR.use_cassette('challenge_verify') do
      challenge = Userbin::Challenge.new(id: 'UWwy5FrWf9DTeoTpJz1LpBp4dPkWZ2Ne')
      challenge.verify(response: '000000')
    end
  end
end

require 'spec_helper'

describe 'Userbin::User' do
  it 'retrieves a user' do
    VCR.use_cassette('user_find') do
      user = Userbin::User.find('9RA2j3cYDxt8gefQUduKnxUxRRGy6Rz4')
      user.email.should == 'brissmyr@gmail.com'
    end
  end

  it 'handles non-existing user' do
    VCR.use_cassette('user_find_non_existing') do
      expect {
        user = Userbin::User.find('non_existing')
      }.to raise_error(Userbin::NotFoundError)
    end
  end
end

require 'spec_helper'
require 'multi_json'

describe 'Userbin::Session' do
  before do
    Userbin.configure do |config|
      config.app_id = '100000000000000'
      config.api_secret = 'test'
    end
  end

  before do
    data = {
      id: "Prars5v7xz2xwWvF5LEqfEUHCoNNsV7V",
      created_at: 1378978281000,
      expires_at: 1378981881000,
      user: {
        confirmed_at: nil,
        created_at: 1378978280000,
        email: "johan@userbin.com",
        id: "TF15JEy7HRxDYx6U435zzEwydKJcptUr",
        last_sign_in_at: nil,
        local_id: nil
      }
    }
    stub_request(:post, /\/users\/.*\/sessions/).to_return(
      status: 200,
      headers: {'X-Userbin-Signature' => 'abcd'},
      body: MultiJson.encode(data)
    )
  end

  xit 'creates a session' do
    allow(OpenSSL::HMAC).to receive(:hexdigest) { 'abcd' }
    user = Userbin::User.new(id: 'guid1')
    session = user.sessions.create
    session.user.email.should == 'johan@userbin.com'
    session.signature.should == 'abcd'
  end
end

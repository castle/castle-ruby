require 'spec_helper'

describe 'Userbin::Session' do

  let(:session_token) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImlzcyI6InVzZXItMjQxMiIsInN1YiI6IlMyb2R4UmVabkdxaHF4UGFRN1Y3a05rTG9Ya0daUEZ6IiwiYXVkIjoiODAwMDAwMDAwMDAwMDAwIiwiZXhwIjoxMzk5NDc5Njc1LCJpYXQiOjEzOTk0Nzk2NjUsImp0aSI6MH0.eyJjaGFsbGVuZ2UiOnsiaWQiOiJUVENqd3VyM3lwbTRUR1ZwWU43cENzTXFxOW9mWEVBSCIsInR5cGUiOiJvdHBfYXV0aGVudGljYXRvciJ9fQ.LT9mUzJEbsizbFxcpMo3zbms0aCDBzfgMbveMGSi1-s' }

  it 'creates a session' do
    VCR.use_cassette('session_create') do
      user_id = 'user-2412'
      session = Userbin::Session.post(
        "users/#{user_id}/sessions", user: {email: 'valid@example.com'})
      Userbin::JWT.new(session.token).header['iss'].should == user_id
    end
  end

  it 'refreshes a session' do
    VCR.use_cassette('session_refresh') do
      session = Userbin::Session.new(token: session_token)
      session = session.refresh(user: {name: 'New Name'})

      session.token.should_not == session_token
    end
  end

  xit 'verifies a session' do
    VCR.use_cassette('session_verify') do
      Userbin::JWT.new(session_token).payload['challenge'].should_not be_nil
      session = Userbin::Session.new(token: session_token)
      session = session.verify(response: '017010')
      Userbin::JWT.new(session.token).payload['challenge'].should be_nil
    end
  end
end

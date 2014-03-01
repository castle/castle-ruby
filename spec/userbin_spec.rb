require 'spec_helper'
require 'cgi'

describe Userbin do
  before do
    Userbin.configure do |config|
      config.app_id = '1000'
      config.api_secret = 'abcd'
    end
  end

  let (:session) do
    {
      "id" => 'xyz',
      "expires_at" => 1478981881000,
      "user" => {
        "id" => 'abc'
      }
    }
  end

  let (:response) do
    Rack::Response.new("", 200, {})
  end

  let (:jwt) do
    JWT.encode(session, 'abcd', 'HS256')
  end

  let (:jwt_bad) do
    JWT.encode(session, 'incorrect', 'HS256')
  end

  context 'when session is created' do

    it 'authenticates with class methods' do
      Userbin.authenticate!(jwt)
      Userbin.should be_authenticated
      Userbin.current_user.id.should == "abc"
    end

    it 'renews' do
      stub_request(:post, /.*userbin\.com.*/).to_return(:status => 200, :body => "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Inh5eiIsImV4cGlyZXNfYXQiOjE0Nzg5ODE4ODEwMDAsInVzZXIiOnsiaWQiOiJhYmMifX0.dwDvu_duq6gHrjHtuEgIyEzcoaM1o0W2CC998hty-O0")
      Userbin.authenticate!(jwt)
      Userbin.current.id.should == 'xyz'
    end

    it 'does not renew' do
      stub_request(:post, /.*userbin\.com.*/).to_return(:status => 404)
      Userbin.authenticate!(jwt)
    end

    it 'authenticate with correct signature' do
      expect {
        Userbin.authenticate!(jwt)
      }.not_to raise_error { Userbin::SecurityError }
    end

    it 'does not authenticate incorrect signature' do
      expect {
        Userbin.authenticate!(jwt_bad)
      }.to raise_error { Userbin::SecurityError }
    end
  end
end

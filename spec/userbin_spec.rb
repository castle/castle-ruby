require 'spec_helper'
require 'cgi'

describe Userbin do
  before do
    Userbin.configure do |config|
      config.app_id = '1000'
      config.api_secret = 'abcd'
    end
  end

  let (:args) do
    {
      "HTTP_COOKIE" => "_ubt=#{JWT.encode(session, 'abcd', 'HS256')} "
    }
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

  let (:request) do
    Rack::Request.new({
      'CONTENT_TYPE' => 'application/json',
      'rack.input' => StringIO.new()
    }.merge(args))
  end

  let (:response) do
    Rack::Response.new("", 200, {})
  end

  context 'when session is created' do

    it 'authenticates with class methods' do
      Userbin.authenticate!(request)
      Userbin.should be_authenticated
      Userbin.current_user.id.should == "abc"
    end

    it 'renews' do
      stub_request(:post, /.*userbin\.com.*/).to_return(:status => 200, :body => "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Inh5eiIsImV4cGlyZXNfYXQiOjE0Nzg5ODE4ODEwMDAsInVzZXIiOnsiaWQiOiJhYmMifX0.dwDvu_duq6gHrjHtuEgIyEzcoaM1o0W2CC998hty-O0")
      Userbin.authenticate!(request)
      Userbin.current.id.should == 'xyz'
    end

    it 'does not renew' do
      stub_request(:post, /.*userbin\.com.*/).to_return(:status => 404)
      Userbin.authenticate!(request)
    end

    it 'authenticate with correct signature' do
      expect {
        Userbin.authenticate!(request)
      }.not_to raise_error { Userbin::SecurityError }
    end

    it 'does not authenticate incorrect signature' do
      Userbin.configure do |config|
        config.api_secret = '1234'
      end
      expect {
        Userbin.authenticate!(request)
      }.to raise_error { Userbin::SecurityError }
    end
  end
end

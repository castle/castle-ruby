require 'spec_helper'
require 'cgi'

describe Userbin do
  before do
    Userbin.configure do |config|
      config.app_id = '1000'
      config.api_secret = '1234'
    end
  end

  let (:args) do
    {
      "HTTP_COOKIE" => "_ubs=abcd; _ubd=#{CGI.escape(MultiJson.encode(session))} "
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
      'HTTP_X_USERBIN_SIGNATURE' => 'abcd',
      'CONTENT_TYPE' => 'application/json',
      'rack.input' => StringIO.new()
    }.merge(args))
  end

  let (:response) do
    Rack::Response.new("", 200, {})
  end

  context 'when session is created' do

    it 'authenticates with class methods' do
      allow(OpenSSL::HMAC).to receive(:hexdigest) { 'abcd' }
      Userbin.authenticate!(request)
      Userbin.should be_authenticated
      Userbin.current_user.id.should == "abc"
    end

    it 'renews' do
      stub_request(:post, /.*userbin\.com.*/).to_return(:status => 200, :body => "{\"id\":\"Prars5v7xz2xwWvF5LEqfEUHCoNNsV7V\",\"created_at\":1378978281000,\"expires_at\":1378981881000,\"user\":{\"confirmed_at\":null,\"created_at\":1378978280000,\"email\":\"admin@getapp6133.com\",\"id\":\"TF15JEy7HRxDYx6U435zzEwydKJcptUr\",\"last_sign_in_at\":null,\"local_id\":null}}", :headers => {'X-Userbin-Signature' => 'abcd'})
      allow(OpenSSL::HMAC).to receive(:hexdigest) { 'abcd' }
      Userbin.authenticate!(request, Time.at(1478981882)) # expired 1s
      Userbin.current.id.should == 'Prars5v7xz2xwWvF5LEqfEUHCoNNsV7V'
    end

    it 'does not renew' do
      stub_request(:post, /.*userbin\.com.*/).to_return(:status => 404)
      allow(OpenSSL::HMAC).to receive(:hexdigest) { 'abcd' }
      Userbin.authenticate!(request, Time.at(1478981882)) # expired 1s
    end

    xit 'authenticate with correct signature' do
      expect {
        Userbin.authenticate!(request)
      }.to raise_error { Userbin::SecurityError }
    end

    it 'does not authenticate incorrect signature' do
      expect {
        Userbin.authenticate!(request)
      }.to raise_error { Userbin::SecurityError }
    end
  end

  context 'when session is deleted' do
    let (:args) do
      {
        "HTTP_COOKIE" => "userbin_signature=abcd;"
      }
    end

    it 'does not authenticate' do
      allow(OpenSSL::HMAC).to receive(:hexdigest) { 'abcd' }
      Userbin.authenticate!(request)
      Userbin.should_not be_authenticated
      Userbin.user.should be_nil
    end
  end

  context 'when params are present' do
    let (:args) do
      {
        "QUERY_STRING" => "userbin_signature=abcd&userbin_data=#{MultiJson.encode(session)}"
      }
    end

    xit 'authenticates with class methods' do
      allow(OpenSSL::HMAC).to receive(:hexdigest) { 'abcd' }
      Userbin.authenticate_events!(request)
    end
  end
end

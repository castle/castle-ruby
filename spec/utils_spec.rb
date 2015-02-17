require 'spec_helper'

class MemoryStore < Castle::TokenStore
  def initialize
    @value = nil
  end

  def session_token
    @value['_ubs']
  end

  def session_token=(value)
    @value['_ubs'] = value
  end

  def trusted_device_token
    @value['_ubt']
  end

  def trusted_device_token=(value)
    @value['_ubt'] = value
  end
end

describe 'Castle utils' do
  describe 'ContextHeaders middleware' do
    before do
      Castle::User.use_api(api = Her::API.new)
      @user = api.setup do |c|
        c.use Castle::Request::Middleware::ContextHeaders
        c.use Her::Middleware::FirstLevelParseJSON
        c.adapter :test do |stub|
          stub.post('/users') do |env|
            @env = env
            [200, {}, [].to_json]
          end
        end
      end
    end

    let(:env) do
      Rack::MockRequest.env_for('/',
        "HTTP_USER_AGENT" => "Mozilla", "REMOTE_ADDR" => "8.8.8.8")
    end

    it 'handles non-existing context headers' do
      Castle::User.create()
    end

    it 'sets context headers from env' do
      request = Rack::Request.new(Rack::MockRequest.env_for('/',
        "HTTP_USER_AGENT" => "Mozilla", "REMOTE_ADDR" => "8.8.8.8"))
      Castle::Client.new(request, session_store: MemoryStore.new)
      Castle::User.create()
      @env['request_headers']['X-Castle-Ip'].should == '8.8.8.8'
      @env['request_headers']['X-Castle-User-Agent'].should == 'Mozilla'
    end
  end
end

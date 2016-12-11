require 'spec_helper'

class Request < Rack::Request
  def delegate?; false; end
end

describe Castle::Client do
  let(:ip) {'1.2.3.4' }
  let(:cookie_id) { 'abcd' }

  it 'parses the request' do
    env = Rack::MockRequest.env_for('/',
      'HTTP_X_FORWARDED_FOR' => '1.2.3.4',
      'HTTP_COOKIE' => "__cid=#{cookie_id};other=efgh"
    )
    req = Request.new(env)

    expect(Castle::API).to receive(:new).with(cookie_id, ip,
      "{\"X-Forwarded-For\":\"#{ip}\"}").and_call_original

    client = Castle::Client.new(req, nil)
    client.authenticate({name: '$login.succeeded', user_id: '1234'})
  end
end

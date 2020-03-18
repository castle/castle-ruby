# frozen_string_literal: true

describe Castle::HeaderFilter do
  subject(:headers) { described_class.new(request).call }

  let(:client_id) { 'abcd' }
  let(:env) do
    Rack::MockRequest.env_for(
      '/',
      'Action-Dispatch.request.content-Type' => 'application/json',
      'HTTP_AUTHORIZATION' => 'Basic 123456',
      'HTTP_COOKIE' => "__cid=#{client_id};other=efgh",
      'HTTP_OK' => 'OK',
      'HTTP_ACCEPT' => 'application/json',
      'HTTP_X_FORWARDED_FOR' => '1.2.3.4',
      'HTTP_USER_AGENT' => 'Mozilla 1234',
      'TEST' => '1',
      'REMOTE_ADDR' => '1.2.3.4'
    )
  end
  let(:filtered) do
    {
      'Accept' => 'application/json',
      'Authorization' => 'Basic 123456',
      'Cookie' => "__cid=#{client_id};other=efgh",
      'Content-Length' => '0',
      'Ok' => 'OK',
      'User-Agent' => 'Mozilla 1234',
      'Remote-Addr' => '1.2.3.4',
      'X-Forwarded-For' => '1.2.3.4'
    }
  end
  let(:request) { Rack::Request.new(env) }

  context 'with list of header' do
    it { expect(headers).to eq(filtered) }
  end
end

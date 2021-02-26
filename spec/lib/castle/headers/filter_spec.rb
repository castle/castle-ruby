# frozen_string_literal: true

describe Castle::Headers::Filter do
  subject(:filter_call) { described_class.new(request).call }

  let(:env) do
    result =
      Rack::MockRequest.env_for(
        '/',
        'Action-Dispatch.request.content-Type' => 'application/json',
        'HTTP_AUTHORIZATION' => 'Basic 123456',
        'HTTP_COOKIE' => '__cid=abcd;other=efgh',
        'HTTP_ACCEPT' => 'application/json',
        'HTTP_X_FORWARDED_FOR' => '1.2.3.4',
        'HTTP_USER_AGENT' => 'Mozilla 1234',
        'TEST' => '1',
        'REMOTE_ADDR' => '1.2.3.4'
      )
    result[:HTTP_OK] = 'OK'
    result
  end
  let(:filtered) do
    {
      'Accept' => 'application/json',
      'Authorization' => 'Basic 123456',
      'Cookie' => '__cid=abcd;other=efgh',
      'Content-Length' => '0',
      'Ok' => 'OK',
      'User-Agent' => 'Mozilla 1234',
      'Remote-Addr' => '1.2.3.4',
      'X-Forwarded-For' => '1.2.3.4'
    }
  end
  let(:request) { Rack::Request.new(env) }

  context 'with list of header' do
    it { expect(filter_call).to eq(filtered) }
  end
end

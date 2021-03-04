# frozen_string_literal: true

describe Castle::Options::GetDefault do
  subject { described_class.new(request, nil) }

  let(:ip) { '1.2.3.4' }
  let(:fingerprint) { 'abcd' }

  let(:env) do
    Rack::MockRequest.env_for(
      '/',
      'HTTP_X_FORWARDED_FOR' => ip,
      'HTTP_ACCEPT_LANGUAGE' => 'en',
      'HTTP_USER_AGENT' => 'test',
      'HTTP_COOKIE' => "__cid=#{fingerprint};other=efgh"
    )
  end
  let(:request) { Rack::Request.new(env) }
  let(:default_context) { subject.call }
  let(:version) { '2.2.0' }
  let(:result_headers) do
    {
      'X-Forwarded-For' => '1.2.3.4',
      'Accept-Language' => 'en',
      'User-Agent' => 'test',
      'Content-Length' => '0',
      'Cookie' => true
    }
  end

  it { expect(default_context[:headers]).to be_eql(result_headers) }
  it { expect(default_context[:ip]).to be_eql(ip) }
  it { expect(default_context[:fingerprint]).to be_eql(fingerprint) }
end

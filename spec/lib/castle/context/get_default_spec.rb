# frozen_string_literal: true

RSpec.describe Castle::Context::GetDefault do
  subject { described_class.new(request) }

  let(:ip) { '1.2.3.4' }

  let(:env) do
    Rack::MockRequest.env_for(
      '/',
      'HTTP_X_FORWARDED_FOR' => ip,
      'HTTP_ACCEPT_LANGUAGE' => 'en',
      'HTTP_USER_AGENT' => 'test',
      'HTTP_COOKIE' => 'other=efgh',
      'HTTP_CONTENT_LENGTH' => '0'
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

  before { stub_const('Castle::VERSION', version) }

  it { expect(default_context[:headers]).to eql(result_headers) }
  it { expect(default_context[:ip]).to eql(ip) }
  it { expect(default_context[:library][:name]).to eql('castle-rb') }
  it { expect(default_context[:library][:version]).to eql(version) }
end

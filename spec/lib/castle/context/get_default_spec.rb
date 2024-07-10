# frozen_string_literal: true

describe Castle::Context::GetDefault do
  subject { described_class.new(request, nil) }

  let(:ip) { '1.2.3.4' }
  let(:client_id) { 'abcd' }

  let(:env) do
    Rack::MockRequest.env_for(
      '/',
      'HTTP_X_FORWARDED_FOR' => ip,
      'HTTP_ACCEPT_LANGUAGE' => 'en',
      'HTTP_USER_AGENT' => 'test',
      'HTTP_COOKIE' => "__cid=#{client_id};other=efgh",
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

  it { expect(default_context[:active]).to be_eql(true) }
  it { expect(default_context[:headers]).to be_eql(result_headers) }
  it { expect(default_context[:ip]).to be_eql(ip) }
  it { expect(default_context[:client_id]).to be_eql(client_id) }
  it { expect(default_context[:library][:name]).to be_eql('castle-rb') }
  it { expect(default_context[:library][:version]).to be_eql(version) }
  it { expect(default_context[:user_agent]).to be_eql('test') }
end

# frozen_string_literal: true

describe Castle::Context::Default do
  subject { described_class.new(request, nil) }

  let(:ip) { '1.2.3.4' }
  let(:cookie_id) { 'abcd' }

  let(:env) do
    Rack::MockRequest.env_for('/',
                              'HTTP_X_FORWARDED_FOR' => ip,
                              'HTTP-Accept-Language' => 'en',
                              'HTTP-User-Agent' => 'test',
                              'HTTP_COOKIE' => "__cid=#{cookie_id};other=efgh")
  end
  let(:request) { Rack::Request.new(env) }
  let(:default_context) { subject.call }
  let(:version) { '2.2.0' }

  before do
    stub_const('Castle::VERSION', version)
  end

  it { expect(default_context[:active]).to be_eql(true) }
  it { expect(default_context[:origin]).to be_eql('web') }
  it {
    expect(default_context[:headers]).to be_eql(
      'Rack.version' => true, 'Rack.input' => true, 'Rack.errors' => true,
      'Rack.multithread' => true, 'Rack.multiprocess' => true, 'Rack.run-Once' => true,
      'Request-Method' => true, 'Server-Name' => true, 'Server-Port' => true,
      'Query-String' => true, 'Path-Info' => true, 'Rack.url-Scheme' => true,
      'Https' => true, 'Script-Name' => true, 'Content-Length' => true,
      'X-Forwarded-For' => '1.2.3.4', 'Accept-Language' => 'en', 'User-Agent' => 'test',
      'Rack.request.cookie-Hash' => true, 'Rack.request.cookie-String' => true,
      'Cookie' => true
    )
  }
  it { expect(default_context[:ip]).to be_eql(ip) }
  it { expect(default_context[:library][:name]).to be_eql('castle-rb') }
  it { expect(default_context[:library][:version]).to be_eql(version) }
  it { expect(default_context[:user_agent]).to be_eql('test') }
end

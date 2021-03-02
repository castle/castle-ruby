# frozen_string_literal: true

describe Castle::Context::Prepare do
  let(:ip) { '1.2.3.4' }
  let(:cookie_id) { 'abcd' }
  let(:ua) { 'Chrome' }
  let(:env) do
    Rack::MockRequest.env_for(
      '/',
      'HTTP_USER_AGENT' => ua,
      'HTTP_X_FORWARDED_FOR' => ip,
      'HTTP_COOKIE' => "__cid=#{cookie_id};other=efgh"
    )
  end
  let(:request) { Rack::Request.new(env) }
  let(:context) do
    { active: true, user_agent: ua, library: { name: 'castle-rb', version: '6.0.0' } }
  end

  let(:headers) do
    { 'Content-Length': '0', 'User-Agent': ua, 'X-Forwarded-For': ip.to_s, 'Cookie': true }
  end

  before { stub_const('Castle::VERSION', '6.0.0') }

  describe '#call' do
    subject(:generated) { described_class.call(request) }

    context 'when active true' do
      it { is_expected.to eql(context) }
    end
  end
end

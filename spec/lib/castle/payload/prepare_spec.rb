# frozen_string_literal: true

describe Castle::Payload::Prepare do
  let(:ip) { '1.2.3.4' }
  let(:cookie_id) { 'abcd' }
  let(:ua) { 'Chrome' }
  let(:env) do
    Rack::MockRequest.env_for(
      '/',
      'HTTP_USER_AGENT' => ua,
      'HTTP_X_FORWARDED_FOR' => ip,
      'HTTP_COOKIE' => "__cid=#{cookie_id};other=efgh",
      'HTTP_CONTENT_LENGTH' => '0'
    )
  end
  let(:request) { Rack::Request.new(env) }

  let(:headers) { { 'Content-Length': '0', 'User-Agent': ua, 'X-Forwarded-For': ip.to_s, Cookie: true } }
  let(:context) do
    {
      client_id: 'abcd',
      active: true,
      user_agent: ua,
      headers: headers,
      ip: ip,
      library: {
        name: 'castle-rb',
        version: '2.2.0'
      }
    }
  end

  let(:time_now) { Time.now }
  let(:time_formatted) { time_now.utc.iso8601(3) }
  let(:payload_options) { { user_id: '1234', user_traits: { name: 'Jo' } } }
  let(:result) { { user_id: '1234', user_traits: { name: 'Jo' }, timestamp: time_formatted, context: context } }

  before do
    Timecop.freeze(time_now)
    stub_const('Castle::VERSION', '2.2.0')
  end

  after { Timecop.return }

  describe '#call' do
    subject(:generated) { described_class.call(payload_options, request) }

    context 'when active true' do
      it { is_expected.to eql(result) }
    end
  end
end

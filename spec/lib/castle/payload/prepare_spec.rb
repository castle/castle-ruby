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
      'HTTP_COOKIE' => "__cid=#{cookie_id};other=efgh"
    )
  end
  let(:request) { Rack::Request.new(env) }

  let(:headers) do
    { 'Content-Length': '0', 'User-Agent': ua, 'X-Forwarded-For': ip.to_s, 'Cookie': true }
  end
  let(:context) { { active: true, library: { name: 'castle-rb', version: '2.2.0' } } }

  let(:time_now) { Time.now }
  let(:time_formatted) { time_now.utc.iso8601(3) }
  let(:payload_options) { { user_id: '1234', user_traits: { name: 'Jo' } } }
  let(:result) do
    { user_id: '1234', user_traits: { name: 'Jo' }, timestamp: time_formatted, context: context }
  end

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

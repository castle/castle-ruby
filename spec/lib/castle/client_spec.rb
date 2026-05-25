# frozen_string_literal: true

RSpec.describe Castle::Client do
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
  let(:client) { described_class.from_request(request) }
  let(:request_to_context) { Castle::Context::Prepare.call(request) }
  let(:client_with_user_timestamp) { described_class.new(context: request_to_context, timestamp: time_user) }
  let(:client_with_no_timestamp) { described_class.new(context: request_to_context) }

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
  let(:time_auto) { time_now.utc.iso8601(3) }
  let(:time_user) { (Time.now - 10_000).utc.iso8601(3) }
  let(:response_body) { {}.to_json }
  let(:response_code) { 200 }

  let(:stub_response) do
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(
      status: response_code,
      body: response_body,
      headers: {}
    )
  end

  before do
    Timecop.freeze(time_now)
    stub_const('Castle::VERSION', '2.2.0')
    stub_response
  end

  after { Timecop.return }

  describe 'parses the request' do
    before { allow(Castle::API).to receive(:send_request).and_call_original }

    it do
      client.risk(event: '$login', status: '$succeeded', user: { id: '1234' })
      expect(Castle::API).to have_received(:send_request)
    end
  end

  describe 'tracked?' do
    context 'when off' do
      before { client.disable_tracking }

      it { expect(client).not_to be_tracked }
    end

    context 'when on' do
      before { client.enable_tracking }

      it { expect(client).to be_tracked }
    end
  end

  describe 'filter' do
    it_behaves_like 'action request', :filter
  end

  describe 'risk' do
    it_behaves_like 'action request', :risk
  end

  describe 'log' do
    it_behaves_like 'action request', :log
  end

  describe 'client action mixins' do
    it_behaves_like 'it has list actions'
    it_behaves_like 'it has list item actions'
    it_behaves_like 'it has privacy actions'
  end
end

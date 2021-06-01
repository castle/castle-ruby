# frozen_string_literal: true

describe Castle::Client do
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
  let(:client) { described_class.from_request(request) }
  let(:request_to_context) { Castle::Context::Prepare.call(request) }
  let(:client_with_user_timestamp) do
    described_class.new(context: request_to_context, timestamp: time_user)
  end
  let(:client_with_no_timestamp) { described_class.new(context: request_to_context) }

  let(:headers) do
    { 'Content-Length': '0', 'User-Agent': ua, 'X-Forwarded-For': ip.to_s, 'Cookie': true }
  end
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

  before do
    Timecop.freeze(time_now)
    stub_const('Castle::VERSION', '2.2.0')
    stub_request(:any, /api.castle.io/)
      .with(basic_auth: ['', 'secret'])
      .to_return(status: 200, body: response_body, headers: {})
  end

  after { Timecop.return }

  describe 'parses the request' do
    before { allow(Castle::API).to receive(:send_request).and_call_original }

    it do
      client.authenticate(event: '$login.succeeded', user_id: '1234')
      expect(Castle::API).to have_received(:send_request)
    end
  end

  describe 'end impersonation' do
    let(:impersonator) { 'test@castle.io' }
    let(:request_body) do
      {
        user_id: '1234',
        timestamp: time_auto,
        sent_at: time_auto,
        properties: {
          impersonator: impersonator
        },
        context: context
      }
    end
    let(:response_body) { { success: true }.to_json }
    let(:options) { { user_id: '1234', properties: { impersonator: impersonator } } }

    context 'when used with symbol keys' do
      before { client.end_impersonation(options) }

      it do
        assert_requested :delete, 'https://api.castle.io/v1/impersonate', times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
        end
      end
    end

    context 'when request is not successful' do
      let(:response_body) { {}.to_json }

      it do
        expect { client.end_impersonation(options) }.to raise_error(Castle::ImpersonationFailed)
      end
    end
  end

  describe 'start impersonation' do
    let(:impersonator) { 'test@castle.io' }
    let(:request_body) do
      {
        user_id: '1234',
        timestamp: time_auto,
        sent_at: time_auto,
        properties: {
          impersonator: impersonator
        },
        context: context
      }
    end
    let(:response_body) { { success: true }.to_json }
    let(:options) { { user_id: '1234', properties: { impersonator: impersonator } } }

    context 'when used with symbol keys' do
      before { client.start_impersonation(options) }

      it do
        assert_requested :post, 'https://api.castle.io/v1/impersonate', times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
        end
      end
    end

    context 'when request is not successful' do
      let(:response_body) { {}.to_json }

      it do
        expect { client.start_impersonation(options) }.to raise_error(Castle::ImpersonationFailed)
      end
    end
  end

  describe 'authenticate' do
    let(:options) { { event: '$login.succeeded', user_id: '1234' } }
    let(:request_response) { client.authenticate(options) }
    let(:request_body) do
      {
        event: '$login.succeeded',
        user_id: '1234',
        context: context,
        timestamp: time_auto,
        sent_at: time_auto
      }
    end

    context 'when used with symbol keys' do
      before { request_response }

      it do
        assert_requested :post, 'https://api.castle.io/v1/authenticate', times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
        end
      end

      context 'when passed timestamp in options and no defined timestamp' do
        let(:client) { client_with_no_timestamp }
        let(:options) { { event: '$login.succeeded', user_id: '1234', timestamp: time_user } }
        let(:request_body) do
          {
            event: '$login.succeeded',
            user_id: '1234',
            context: context,
            timestamp: time_user,
            sent_at: time_auto
          }
        end

        it do
          assert_requested :post, 'https://api.castle.io/v1/authenticate', times: 1 do |req|
            JSON.parse(req.body) == JSON.parse(request_body.to_json)
          end
        end
      end

      context 'with client initialized with timestamp' do
        let(:client) { client_with_user_timestamp }
        let(:request_body) do
          {
            event: '$login.succeeded',
            user_id: '1234',
            context: context,
            timestamp: time_user,
            sent_at: time_auto
          }
        end

        it do
          assert_requested :post, 'https://api.castle.io/v1/authenticate', times: 1 do |req|
            JSON.parse(req.body) == JSON.parse(request_body.to_json)
          end
        end
      end
    end

    context 'when used with string keys' do
      let(:options) { { 'event' => '$login.succeeded', 'user_id' => '1234' } }

      before { request_response }

      it do
        assert_requested :post, 'https://api.castle.io/v1/authenticate', times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
        end
      end
    end

    context 'when tracking enabled' do
      before { request_response }

      it do
        assert_requested :post, 'https://api.castle.io/v1/authenticate', times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
        end
      end

      it { expect(request_response[:failover]).to be false }
      it { expect(request_response[:failover_reason]).to be_nil }
    end

    context 'when tracking disabled' do
      before do
        client.disable_tracking
        request_response
      end

      it { assert_not_requested :post, 'https://api.castle.io/v1/authenticate' }
      it { expect(request_response[:action]).to be_eql(Castle::Verdict::ALLOW) }
      it { expect(request_response[:user_id]).to be_eql('1234') }
      it { expect(request_response[:failover]).to be true }
      it { expect(request_response[:failover_reason]).to be_eql('Castle is set to do not track.') }
    end

    context 'when request with fail' do
      before do
        allow(Castle::API).to receive(:send_request).and_raise(
          Castle::RequestError.new(Timeout::Error)
        )
      end

      context 'with request error and throw strategy' do
        before { allow(Castle.config).to receive(:failover_strategy).and_return(:throw) }

        it { expect { request_response }.to raise_error(Castle::RequestError) }
      end

      context 'with request error and not throw on eg deny strategy' do
        it { assert_not_requested :post, 'https://:secret@api.castle.io/v1/authenticate' }
        it { expect(request_response[:action]).to be_eql('allow') }
        it { expect(request_response[:user_id]).to be_eql('1234') }
        it { expect(request_response[:failover]).to be true }
        it { expect(request_response[:failover_reason]).to be_eql('Castle::RequestError') }
      end
    end

    context 'when request is internal server error' do
      before do
        allow(Castle::API).to receive(:send_request).and_raise(Castle::InternalServerError)
      end

      describe 'throw strategy' do
        before { allow(Castle.config).to receive(:failover_strategy).and_return(:throw) }

        it { expect { request_response }.to raise_error(Castle::InternalServerError) }
      end

      describe 'not throw on eg deny strategy' do
        it { assert_not_requested :post, 'https://:secret@api.castle.io/v1/authenticate' }
        it { expect(request_response[:action]).to be_eql('allow') }
        it { expect(request_response[:user_id]).to be_eql('1234') }
        it { expect(request_response[:failover]).to be true }
        it { expect(request_response[:failover_reason]).to be_eql('Castle::InternalServerError') }
      end
    end
  end

  describe 'track' do
    let(:request_body) do
      {
        event: '$login.succeeded',
        context: context,
        user_id: '1234',
        timestamp: time_auto,
        sent_at: time_auto
      }
    end

    before { client.track(options) }

    context 'when used with symbol keys' do
      let(:options) { { event: '$login.succeeded', user_id: '1234' } }

      it do
        assert_requested :post, 'https://api.castle.io/v1/track', times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
        end
      end

      context 'when passed timestamp in options and no defined timestamp' do
        let(:client) { client_with_no_timestamp }
        let(:options) { { event: '$login.succeeded', user_id: '1234', timestamp: time_user } }
        let(:request_body) do
          {
            event: '$login.succeeded',
            user_id: '1234',
            context: context,
            timestamp: time_user,
            sent_at: time_auto
          }
        end

        it do
          assert_requested :post, 'https://api.castle.io/v1/track', times: 1 do |req|
            JSON.parse(req.body) == JSON.parse(request_body.to_json)
          end
        end
      end

      context 'with client initialized with timestamp' do
        let(:client) { client_with_user_timestamp }
        let(:request_body) do
          {
            event: '$login.succeeded',
            context: context,
            user_id: '1234',
            timestamp: time_user,
            sent_at: time_auto
          }
        end

        it do
          assert_requested :post, 'https://api.castle.io/v1/track', times: 1 do |req|
            JSON.parse(req.body) == JSON.parse(request_body.to_json)
          end
        end
      end
    end

    context 'when used with string keys' do
      let(:options) { { 'event' => '$login.succeeded', 'user_id' => '1234' } }

      it do
        assert_requested :post, 'https://api.castle.io/v1/track', times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
        end
      end
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
end

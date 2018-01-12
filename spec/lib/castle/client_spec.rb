# frozen_string_literal: true

describe Castle::Client do
  let(:ip) { '1.2.3.4' }
  let(:cookie_id) { 'abcd' }
  let(:env) do
    Rack::MockRequest.env_for(
      '/',
      'HTTP_X_FORWARDED_FOR' => ip,
      'HTTP_COOKIE' => "__cid=#{cookie_id};other=efgh"
    )
  end
  let(:request) { Rack::Request.new(env) }
  let(:client) { described_class.from_request(request) }
  let(:request_to_context) { described_class.to_context(request) }
  let(:client_with_user_timestamp) do
    described_class.new(request_to_context, timestamp: time_user)
  end
  let(:client_with_no_timestamp) { described_class.new(request_to_context) }

  let(:headers) { { 'X-Forwarded-For' => ip.to_s } }
  let(:context) do
    {
      client_id: 'abcd',
      active: true,
      origin: 'web',
      headers: { 'X-Forwarded-For': ip.to_s },
      ip: ip,
      library: { name: 'castle-rb', version: '2.2.0' }
    }
  end

  let(:time_now) { Time.now }
  let(:time_auto) { time_now.utc.iso8601(3) }
  let(:time_user) { (Time.now - 10_000).utc.iso8601(3) }

  before do
    Timecop.freeze(time_now)
    stub_const('Castle::VERSION', '2.2.0')
    stub_request(:any, /api.castle.io/).with(
      basic_auth: ['', 'secret']
    ).to_return(status: 200, body: '{}', headers: {})
  end

  after do
    Timecop.return
  end

  describe 'parses the request' do
    before do
      allow(Castle::API).to receive(:new).and_call_original
    end

    it do
      client.authenticate(event: '$login.succeeded', user_id: '1234')
      expect(Castle::API).to have_received(:new)
    end
  end

  describe 'to_context' do
    it do
      expect(described_class.to_context(request)).to eql(context)
    end
  end

  describe 'to_options' do
    let(:options) { { user_id: '1234', traits: { name: 'Jo' } } }
    let(:result) { { user_id: '1234', traits: { name: 'Jo' }, timestamp: time_auto } }

    it do
      expect(described_class.to_options(options)).to eql(result)
    end
  end

  describe 'identify' do
    let(:request_body) do
      { user_id: '1234', timestamp: time_auto,
        sent_at: time_auto, context: context, traits: { name: 'Jo' } }
    end

    before { client.identify(options) }

    context 'symbol keys' do
      let(:options) { { user_id: '1234', traits: { name: 'Jo' } } }

      it do
        assert_requested :post, 'https://api.castle.io/v1/identify', times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
        end
      end

      context 'when passed timestamp in options and no defined timestamp' do
        let(:client) { client_with_no_timestamp }
        let(:options) { { user_id: '1234', traits: { name: 'Jo' }, timestamp: time_user } }
        let(:request_body) do
          { user_id: '1234', traits: { name: 'Jo' }, context: context,
            timestamp: time_user, sent_at: time_auto }
        end

        it do
          assert_requested :post, 'https://api.castle.io/v1/identify', times: 1 do |req|
            JSON.parse(req.body) == JSON.parse(request_body.to_json)
          end
        end
      end

      context 'with client initialized with timestamp' do
        let(:client) { client_with_user_timestamp }
        let(:request_body) do
          { user_id: '1234', timestamp: time_user, sent_at: time_auto,
            context: context, traits: { name: 'Jo' } }
        end

        it do
          assert_requested :post, 'https://api.castle.io/v1/identify', times: 1 do |req|
            JSON.parse(req.body) == JSON.parse(request_body.to_json)
          end
        end
      end
    end

    context 'string keys' do
      let(:options) { { 'user_id' => '1234', 'traits' => { 'name' => 'Jo' } } }

      it do
        assert_requested :post, 'https://api.castle.io/v1/identify', times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
        end
      end
    end
  end

  describe 'authenticate' do
    let(:options) { { event: '$login.succeeded', user_id: '1234' } }
    let(:request_response) { client.authenticate(options) }
    let(:request_body) do
      { event: '$login.succeeded', user_id: '1234', context: context,
        timestamp: time_auto, sent_at: time_auto }
    end

    context 'symbol keys' do
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
          { event: '$login.succeeded', user_id: '1234', context: context,
            timestamp: time_user, sent_at: time_auto }
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
          { event: '$login.succeeded', user_id: '1234', context: context,
            timestamp: time_user, sent_at: time_auto }
        end

        it do
          assert_requested :post, 'https://api.castle.io/v1/authenticate', times: 1 do |req|
            JSON.parse(req.body) == JSON.parse(request_body.to_json)
          end
        end
      end
    end

    context 'string keys' do
      let(:options) { { 'event' => '$login.succeeded', 'user_id' => '1234' } }

      before { request_response }

      it do
        assert_requested :post, 'https://api.castle.io/v1/authenticate', times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
        end
      end
    end

    context 'tracking enabled' do
      before { request_response }

      it do
        assert_requested :post, 'https://api.castle.io/v1/authenticate', times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
        end
      end

      it { expect(request_response[:failover]).to be false }
      it { expect(request_response[:failover_reason]).to be_nil }
    end

    context 'tracking disabled' do
      before do
        client.disable_tracking
        request_response
      end

      it { assert_not_requested :post, 'https://api.castle.io/v1/authenticate' }
      it { expect(request_response[:action]).to be_eql('allow') }
      it { expect(request_response[:user_id]).to be_eql('1234') }
      it { expect(request_response[:failover]).to be true }
      it { expect(request_response[:failover_reason]).to be_eql('Castle set to do not track.') }
    end

    context 'when request with fail' do
      before { allow(client.api).to receive(:request).and_raise(Castle::RequestError) }

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
      before { allow(client.api).to receive(:request).and_raise(Castle::InternalServerError) }

      context 'throw strategy' do
        before { allow(Castle.config).to receive(:failover_strategy).and_return(:throw) }

        it { expect { request_response }.to raise_error(Castle::InternalServerError) }
      end

      context 'not throw on eg deny strategy' do
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
      { event: '$login.succeeded', context: context, user_id: '1234',
        timestamp: time_auto, sent_at: time_auto }
    end

    before { client.track(options) }

    context 'symbol keys' do
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
          { event: '$login.succeeded', user_id: '1234', context: context,
            timestamp: time_user, sent_at: time_auto }
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
          { event: '$login.succeeded', context: context, user_id: '1234',
            timestamp: time_user, sent_at: time_auto }
        end

        it do
          assert_requested :post, 'https://api.castle.io/v1/track', times: 1 do |req|
            JSON.parse(req.body) == JSON.parse(request_body.to_json)
          end
        end
      end
    end

    context 'string keys' do
      let(:options) { { 'event' => '$login.succeeded', 'user_id' => '1234' } }

      it do
        assert_requested :post, 'https://api.castle.io/v1/track', times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
        end
      end
    end
  end

  describe 'tracked?' do
    context 'off' do
      before { client.disable_tracking }

      it { expect(client).not_to be_tracked }
    end

    context 'on' do
      before { client.enable_tracking }

      it { expect(client).to be_tracked }
    end
  end
end

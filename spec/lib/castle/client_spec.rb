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
  let(:headers) { { 'X-Forwarded-For' => ip.to_s } }
  let(:context) do
    {
      client_id: 'abcd',
      active: true,
      origin: 'web',
      headers: headers,
      ip: ip,
      library: { name: 'castle-rb', version: '2.2.0' }
    }
  end

  before do
    stub_const('Castle::VERSION', '2.2.0')
    stub_request(:any, /api.castle.io/).with(
      basic_auth: ['', 'secret']
    ).to_return(status: 200, body: '{}', headers: {})
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

  describe 'identify' do
    let(:request_body) { { user_id: '1234', context: context, traits: { name: 'Jo' } } }

    before { client.identify(options) }

    context 'symbol keys' do
      let(:options) { { user_id: '1234', traits: { name: 'Jo' } } }

      it do
        assert_requested :post, 'https://api.castle.io/v1/identify', times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
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
    let(:request_body) { { event: '$login.succeeded', user_id: '1234', context: context } }

    context 'symbol keys' do
      before { request_response }

      it do
        assert_requested :post, 'https://api.castle.io/v1/authenticate', times: 1 do |req|
          req.body == request_body.to_json
        end
      end
    end

    context 'string keys' do
      let(:options) { { 'event' => '$login.succeeded', 'user_id' => '1234' } }

      before { request_response }

      it do
        assert_requested :post, 'https://api.castle.io/v1/authenticate', times: 1 do |req|
          req.body == request_body.to_json
        end
      end
    end

    context 'tracking enabled' do
      before { request_response }

      it do
        assert_requested :post, 'https://api.castle.io/v1/authenticate', times: 1 do |req|
          req.body == request_body.to_json
        end
      end

      it { expect(request_response['failover']).to be false }
      it { expect(request_response['failover_reason']).to be_nil }
    end

    context 'tracking disabled' do
      before do
        client.disable_tracking
        request_response
      end

      it { assert_not_requested :post, 'https://api.castle.io/v1/authenticate' }
      it { expect(request_response['action']).to be_eql('allow') }
      it { expect(request_response['user_id']).to be_eql('1234') }
      it { expect(request_response['failover']).to be true }
      it { expect(request_response['failover_reason']).to be_eql('Castle set to do not track.') }
    end

    context 'when request with fail' do
      before { allow(client.api).to receive(:request).and_raise(Castle::RequestError) }

      context 'with request error and throw strategy' do
        before { allow(Castle.config).to receive(:failover_strategy).and_return(:throw) }

        it { expect { request_response }.to raise_error(Castle::RequestError) }
      end

      context 'with request error and not throw on eg deny strategy' do
        it { assert_not_requested :post, 'https://:secret@api.castle.io/v1/authenticate' }
        it { expect(request_response['action']).to be_eql('allow') }
        it { expect(request_response['user_id']).to be_eql('1234') }
        it { expect(request_response['failover']).to be true }
        it { expect(request_response['failover_reason']).to be_eql('Castle::RequestError') }
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
        it { expect(request_response['action']).to be_eql('allow') }
        it { expect(request_response['user_id']).to be_eql('1234') }
        it { expect(request_response['failover']).to be true }
        it { expect(request_response['failover_reason']).to be_eql('Castle::InternalServerError') }
      end
    end
  end

  describe 'track' do
    let(:request_body) { { event: '$login.succeeded', context: context, user_id: '1234' } }

    before { client.track(options) }

    context 'symbol keys' do
      let(:options) { { event: '$login.succeeded', user_id: '1234' } }

      it do
        assert_requested :post, 'https://api.castle.io/v1/track', times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
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

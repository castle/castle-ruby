# frozen_string_literal: true

describe Castle::API::Authenticate do
  subject(:call_subject) { described_class.call(options) }

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
  let(:context) { Castle::Context::Prepare.call(request) }
  let(:time_now) { Time.now }
  let(:time_auto) { time_now.utc.iso8601(3) }
  let(:time_user) { (Time.now - 10_000).utc.iso8601(3) }
  let(:response_body) { {}.to_json }

  before do
    Timecop.freeze(time_now)
    stub_const('Castle::VERSION', '2.2.0')
  end

  after { Timecop.return }

  describe '.call' do
    let(:request_body) do
      {
        event: '$login.succeeded',
        context: context,
        user_id: '1234',
        sent_at: time_auto
      }
    end

    context 'when used with symbol keys' do
      before do
        stub_request(:any, /api.castle.io/)
          .with(basic_auth: ['', 'secret'])
          .to_return(status: 200, body: response_body, headers: {})
        call_subject
      end

      let(:options) do
        { event: '$login.succeeded', user_id: '1234', context: context }
      end

      it do
        assert_requested :post,
                         'https://api.castle.io/v1/authenticate',
                         times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
        end
      end

      context 'when passed timestamp in options and no defined timestamp' do
        let(:options) do
          {
            event: '$login.succeeded',
            user_id: '1234',
            timestamp: time_user,
            context: context
          }
        end
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
          assert_requested :post,
                           'https://api.castle.io/v1/authenticate',
                           times: 1 do |req|
            JSON.parse(req.body) == JSON.parse(request_body.to_json)
          end
        end
      end
    end

    context 'when denied' do
      let(:failover_appendix) { { failover: false, failover_reason: nil } }

      let(:options) do
        { event: '$login.succeeded', user_id: '1234', context: context }
      end

      context 'when denied without any risk policy' do
        let(:response_body) { deny_response_without_rp.to_json }
        let(:deny_response_without_rp) do
          { action: 'deny', user_id: '12345', device_token: 'abcdefg1234' }
        end
        let(:deny_without_rp_failover_result) do
          deny_response_without_rp.merge(failover_appendix)
        end

        before do
          stub_request(:any, /api.castle.io/)
            .with(basic_auth: ['', 'secret'])
            .to_return(
              status: 200,
              body: deny_response_without_rp.to_json,
              headers: {}
            )
          call_subject
        end

        it do
          assert_requested :post,
                           'https://api.castle.io/v1/authenticate',
                           times: 1 do |req|
            JSON.parse(req.body) == JSON.parse(request_body.to_json)
          end
        end

        it { expect(call_subject).to eql(deny_without_rp_failover_result) }
      end

      context 'when denied with risk policy' do
        let(:deny_response_with_rp) do
          {
            action: 'deny',
            user_id: '12345',
            device_token: 'abcdefg1234',
            risk_policy: {
              id: 'q-rbeMzBTdW2Fd09sbz55A',
              revision_id: 'pke4zqO2TnqVr-NHJOAHEg',
              name: 'Block Users from X',
              type: 'bot'
            }
          }
        end
        let(:response_body) { deny_response_with_rp.to_json }
        let(:deny_with_rp_failover_result) do
          deny_response_with_rp.merge(failover_appendix)
        end

        before do
          stub_request(:any, /api.castle.io/)
            .with(basic_auth: ['', 'secret'])
            .to_return(
              status: 200,
              body: deny_response_with_rp.to_json,
              headers: {}
            )
          call_subject
        end

        it do
          assert_requested :post,
                           'https://api.castle.io/v1/authenticate',
                           times: 1 do |req|
            JSON.parse(req.body) == JSON.parse(request_body.to_json)
          end
        end

        it { expect(call_subject).to eql(deny_with_rp_failover_result) }
      end
    end
  end
end

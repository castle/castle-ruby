# frozen_string_literal: true

describe Castle::API::Identify do
  subject(:call) { described_class.call(options) }

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
    stub_request(:any, /api.castle.io/)
      .with(basic_auth: ['', 'secret'])
      .to_return(status: 200, body: response_body, headers: {})
  end

  after { Timecop.return }

  describe '.call' do
    let(:request_body) do
      { event: '$login', context: context, user_id: '1234', sent_at: time_auto }
    end

    before { call }

    context 'when used with symbol keys' do
      let(:options) { { event: '$login', user_id: '1234', context: context } }

      it do
        assert_requested :post, 'https://api.castle.io/v1/identify', times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
        end
      end

      context 'when passed timestamp in options and no defined timestamp' do
        let(:options) do
          { event: '$login', user_id: '1234', timestamp: time_user, context: context }
        end
        let(:request_body) do
          {
            event: '$login',
            user_id: '1234',
            context: context,
            timestamp: time_user,
            sent_at: time_auto
          }
        end

        it do
          assert_requested :post, 'https://api.castle.io/v1/identify', times: 1 do |req|
            JSON.parse(req.body) == JSON.parse(request_body.to_json)
          end
        end
      end
    end
  end
end

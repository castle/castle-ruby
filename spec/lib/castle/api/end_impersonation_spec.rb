# frozen_string_literal: true

describe Castle::API::EndImpersonation do
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

  before do
    Timecop.freeze(time_now)
    stub_const('Castle::VERSION', '2.2.0')
    stub_request(:any, /api.castle.io/).with(basic_auth: ['', 'secret']).to_return(
      status: 200,
      body: response_body,
      headers: {
      }
    )
  end

  after { Timecop.return }

  describe 'call' do
    let(:impersonator) { 'test@castle.io' }
    let(:request_body) do
      { user_id: '1234', sent_at: time_auto, properties: { impersonator: impersonator }, context: context }
    end
    let(:response_body) { { success: true }.to_json }
    let(:options) { { user_id: '1234', properties: { impersonator: impersonator }, context: context } }

    context 'when used with symbol keys' do
      before { call }

      it do
        assert_requested :delete, 'https://api.castle.io/v1/impersonate', times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
        end
      end
    end

    context 'when request is not successful' do
      let(:response_body) { {}.to_json }

      it { expect { call }.to raise_error(Castle::ImpersonationFailed) }
    end
  end
end

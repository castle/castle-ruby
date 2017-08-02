# frozen_string_literal: true

require 'spec_helper'

describe Castle::Client do
  let(:ip) { '1.2.3.4' }
  let(:cookie_id) { 'abcd' }
  let(:env) do
    Rack::MockRequest.env_for('/',
                              'HTTP_X_FORWARDED_FOR' => ip,
                              'HTTP_COOKIE' => "__cid=#{cookie_id};other=efgh")
  end
  let(:request) { Rack::Request.new(env) }
  let(:client) { described_class.new(request) }
  let(:review_id) { '12356789' }
  let(:headers) { { 'X-Forwarded-For' => ip.to_s } }
  let(:context) do
    {
      client_id: 'abcd',
      active: true,
      origin: 'web',
      request_headers: headers,
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

  it 'identifies' do
    client.identify(user_id: '1234', traits: { name: 'Jo' })
    assert_requested :post, 'https://api.castle.io/v1/identify',
                     times: 1,
                     body: { user_id: '1234', context: context, traits: { name: 'Jo' } }.to_json
  end

  it 'authenticates' do
    client.authenticate(event: '$login.succeeded', user_id: '1234')
    assert_requested :post, 'https://api.castle.io/v1/authenticate',
                     times: 1 do |req|
      req.body == { event: '$login.succeeded', user_id: '1234', context: context }.to_json
    end
  end

  it 'tracks' do
    client.track(event: '$login.succeeded', user_id: '1234')
    assert_requested :post, 'https://api.castle.io/v1/track',
                     times: 1,
                     body: { event: '$login.succeeded', context: context, user_id: '1234' }.to_json
  end

  it 'fetches review' do
    client.fetch_review(review_id)

    assert_requested :get,
                     "https://api.castle.io/v1/reviews/#{review_id}",
                     times: 1
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

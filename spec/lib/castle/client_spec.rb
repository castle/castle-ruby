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
    { active: true,
      origin: 'web',
      request: { headers: headers },
      ip: ip,
      library: { name: 'castle-rb', version: '2.2.0' } }
  end

  before do
    stub_const('Castle::VERSION', '2.2.0')
  end

  before do
    stub_request(:any, /api.castle.io/).to_return(status: 200, body: '{}', headers: {})
  end

  describe 'parses the request' do
    # rubocop:disable Metrics/LineLength
    let(:castle_headers) do
      { 'Content-Type' => 'application/json',
        'User-Agent' => 'Castle/v1 RubyBindings/2.2.0',
        'X-Castle-Client-Id' => 'abcd',
        'X-Castle-Ip' => '1.2.3.4',
        'X-Castle-Headers' => JSON.generate(headers),
        'X-Castle-Source' => 'web',
        'X-Castle-Client-User-Agent' =>
          %({"bindings_version":"2.2.0","lang":"ruby","lang_version":"2.4.1-p111 (2017-03-22)","platform":"x86_64-apple-darwin16.4.0","publisher":"castle","uname":"Darwin Kernel Version 16.7.0"}) }
    end

    # rubocop:enable Metrics/LineLength

    before do
      allow(Castle::System).to receive(:ruby_version).and_return('2.4.1-p111 (2017-03-22)')
      allow(Castle::System).to receive(:platform).and_return('x86_64-apple-darwin16.4.0')
      allow(Castle::System).to receive(:uname).and_return('Darwin Kernel Version 16.7.0')
      allow(Castle::API).to receive(:new).with(castle_headers).and_call_original
    end

    it do
      client.authenticate(event: '$login.succeeded', user_id: '1234')
      expect(Castle::API).to have_received(:new).with(castle_headers)
    end
  end

  it 'identifies' do
    client.identify(user_id: '1234', traits: { name: 'Jo' })
    assert_requested :post, 'https://:secret@api.castle.io/v1/identify',
                     times: 1,
                     body: { user_id: '1234', context: context, traits: { name: 'Jo' } }
  end

  it 'authenticates' do
    client.authenticate(event: '$login.succeeded', user_id: '1234')
    assert_requested :post, 'https://:secret@api.castle.io/v1/authenticate',
                     times: 1,
                     body: { event: '$login.succeeded', context: context, user_id: '1234' }
  end

  it 'tracks' do
    client.track(event: '$login.succeeded', user_id: '1234')
    assert_requested :post, 'https://:secret@api.castle.io/v1/track',
                     times: 1,
                     body: { event: '$login.succeeded', context: context, user_id: '1234' }
  end

  it 'fetches review' do
    client.fetch_review(review_id)

    assert_requested :get,
                     "https://:secret@api.castle.io/v1/reviews/#{review_id}",
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

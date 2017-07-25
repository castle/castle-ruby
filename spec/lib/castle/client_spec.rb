# frozen_string_literal: true

require 'spec_helper'

class Request < Rack::Request
  def delegate?
    false
  end
end

describe Castle::Client do
  let(:ip) { '1.2.3.4' }
  let(:cookie_id) { 'abcd' }
  let(:env) do
    Rack::MockRequest.env_for('/',
                              'HTTP_X_FORWARDED_FOR' => '1.2.3.4',
                              'HTTP_COOKIE' => "__cid=#{cookie_id};other=efgh")
  end
  let(:request) { Request.new(env) }
  let(:client) { described_class.new(request) }
  let(:review_id) { '12356789' }

  describe 'parses the request' do
    let(:api_data) { [cookie_id, ip, "{\"X-Forwarded-For\":\"#{ip}\"}"] }

    before do
      allow(Castle::API).to receive(:new).with(*api_data).and_call_original
    end

    it do
      client.authenticate(name: '$login.succeeded', user_id: '1234')
      expect(Castle::API).to have_received(:new).with(*api_data)
    end
  end

  it 'identifies' do
    client.identify(user_id: '1234', traits: { name: 'Jo' })
    assert_requested :post, 'https://:secret@api.castle.io/v1/identify',
                     times: 1,
                     body: { user_id: '1234', traits: { name: 'Jo' } }
  end

  it 'authenticates' do
    client.authenticate(name: '$login.succeeded', user_id: '1234')
    assert_requested :post, 'https://:secret@api.castle.io/v1/authenticate',
                     times: 1,
                     body: { name: '$login.succeeded', user_id: '1234' }
  end

  it 'tracks' do
    client.track(name: '$login.succeeded', user_id: '1234')
    assert_requested :post, 'https://:secret@api.castle.io/v1/track',
                     times: 1,
                     body: { name: '$login.succeeded', user_id: '1234' }
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

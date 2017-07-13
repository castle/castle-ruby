# frozen_string_literal: true

require 'spec_helper'

class Request < Rack::Request
  def delegate?
    false
  end
end

describe Castle::Client do
  let(:ip) { '1.2.3.4' }
  let(:client_id) { 'abcd' }
  let(:env) do
    Rack::MockRequest.env_for('/',
                              'HTTP_X_FORWARDED_FOR' => '1.2.3.4',
                              'HTTP_COOKIE' => "__cid=#{client_id};other=efgh")
  end
  let(:request) { Request.new(env) }
  let(:client) { Castle::Client.new(request, nil) }
  let(:review_id) { '12356789' }

  context 'with X-Castle-Client-Id header' do
    let(:env) do
      Rack::MockRequest.env_for('/',
                              'HTTP_X_FORWARDED_FOR' => '1.2.3.4',
                              'HTTP_X_CASTLE_CLIENT_ID' => client_id)
    end
    it 'appends the client_id' do
      expect(Castle::API).to receive(:new).with(client_id, ip,
                                              anything).and_call_original

      client = Castle::Client.new(request, nil)
      client.authenticate(name: '$login.succeeded', user_id: '1234')
    end
  end


  it 'parses the request' do
    expect(Castle::API).to receive(:new).with(client_id, ip,
                                              "{\"X-Forwarded-For\":\"#{ip}\"}").and_call_original

    client = Castle::Client.new(request, nil)
    client.authenticate(name: '$login.succeeded', user_id: '1234')
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

    assert_requested :get, "https://:secret@api.castle.io/v1/reviews/#{review_id}",
                     times: 1
  end
end

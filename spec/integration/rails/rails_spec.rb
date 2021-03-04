# frozen_string_literal: true

require 'spec_helper'
require_relative 'support/all'

RSpec.describe HomeController, type: :request do
  context 'with index pages' do
    let(:headers) do
      { 'HTTP_AUTHORIZATION' => 'Basic 123', 'HTTP_X_FORWARDED_FOR' => '5.5.5.5, 1.2.3.4' }
    end
    let(:request) do
      {
        'event' => '$login',
        'user_id' => '123',
        'properties' => {
          'key' => 'value'
        },
        'user_traits' => {
          'key' => 'value'
        },
        'timestamp' => now.utc.iso8601(3),
        'sent_at' => now.utc.iso8601(3),
        'context' => {
          'active' => true,
          'library' => {
            'name' => 'castle-rb',
            'version' => Castle::VERSION
          }
        }
      }
    end

    let(:req_headers) do
      {
        'Content-Length' => '0',
        'Remote-Addr' => '127.0.0.1',
        'Host' => 'www.example.com',
        'Accept' =>
          'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5',
        'Authorization' => true,
        'X-Forwarded-For' => '5.5.5.5, 1.2.3.4',
        'Cookie' => true
      }
    end

    let(:request_with_default_options) do
      request.merge({ 'headers' => req_headers, 'ip' => '1.2.3.4', 'fingerprint' => '' })
    end

    let(:now) { Time.now }

    before do
      Timecop.freeze(now)
      stub_request(:post, 'https://api.castle.io/v1/track')
    end

    after { Timecop.return }

    describe '#index1' do
      before { get '/index1', headers: headers }

      it do
        assert_requested :post, 'https://api.castle.io/v1/track', times: 1 do |req|
          JSON.parse(req.body) == request
        end
      end

      it { expect(response).to be_successful }
    end

    describe '#index2' do
      before { get '/index2', headers: headers }

      it do
        assert_requested :post, 'https://api.castle.io/v1/track', times: 1 do |req|
          JSON.parse(req.body) == request_with_default_options
        end
      end

      it { expect(response).to be_successful }
    end

    describe '#index3' do
      before { get '/index3', headers: headers }

      it do
        assert_requested :post, 'https://api.castle.io/v1/track', times: 1 do |req|
          JSON.parse(req.body) == request_with_default_options
        end
      end

      it { expect(response).to be_successful }
    end
  end
end

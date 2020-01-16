# frozen_string_literal: true

require 'spec_helper'
require_relative 'support/all'

RSpec.describe HomeController, type: :request do
  describe '#index' do
    let(:request) do
      {
        'event' => '$login.succeeded',
        'user_id' => '123',
        'properties' => { 'key' => 'value' },
        'user_traits' => { 'key' => 'value' },
        'timestamp' => now.utc.iso8601(3),
        'sent_at' => now.utc.iso8601(3),
        'context' => {
          'client_id' => '',
          'active' => true,
          'origin' => 'web',
          'headers' => {
            'Accept' =>
              'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5',
            'Authorization' => true,
            'Content-Length' => '0',
            'Cookie' => true,
            'Host' => 'www.example.com',
            'X-Forwarded-For' => '5.5.5.5, 1.2.3.4'
          },
          'ip' => '1.2.3.4',
          'library' => {
            'name' => 'castle-rb',
            'version' => Castle::VERSION
          }
        }
      }
    end
    let(:now) { Time.now }
    let(:headers) do
      {
        'HTTP_AUTHORIZATION' => 'Basic 123',
        'HTTP_X_FORWARDED_FOR' => '5.5.5.5, 1.2.3.4'
      }
    end

    before do
      Timecop.freeze(now)
      stub_request(:post, 'https://api.castle.io/v1/track')
      get '/', headers: headers
    end

    after { Timecop.return }

    it do
      assert_requested :post, 'https://api.castle.io/v1/track', times: 1 do |req|
        JSON.parse(req.body) == request
      end
    end

    it { expect(response).to be_successful }
  end
end

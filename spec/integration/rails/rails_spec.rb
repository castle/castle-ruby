# frozen_string_literal: true

require 'spec_helper'
require_relative 'support/all'

RSpec.describe HomeController, type: :request do
  context 'with index pages' do
    let(:now) { Time.now }
    let(:headers) do
      {
        'HTTP_AUTHORIZATION' => 'Basic 123',
        'HTTP_X_FORWARDED_FOR' => '5.5.5.5, 1.2.3.4',
        'HTTP_VERSION' => 'HTTP/1.0',
        'HTTP_CONTENT_LENGTH' => '0'
      }
    end

    before do
      Timecop.freeze(now)
      stub_request(:post, 'https://api.castle.io/v1/risk')
    end

    after { Timecop.return }

    describe '#index1' do
      before { get '/index1', headers: headers }

      it { assert_requested :post, 'https://api.castle.io/v1/risk', times: 1 }
      it { expect(response).to be_successful }
    end

    describe '#index2' do
      before { get '/index2', headers: headers }

      it { assert_requested :post, 'https://api.castle.io/v1/risk', times: 1 }
      it { expect(response).to be_successful }
    end

    describe '#index3' do
      before { get '/index3', headers: headers }

      it { assert_requested :post, 'https://api.castle.io/v1/risk', times: 1 }
      it { expect(response).to be_successful }
    end
  end
end

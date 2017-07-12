# frozen_string_literal: true

require 'spec_helper'

describe Castle::API do
  let(:api) { described_class.new('abcd', '1.2.3.4', '{}') }
  let(:api_endpoint) { 'http://new.herokuapp.com:3000/v2' }

  describe 'handles timeout' do
    before do
      stub_request(:any, /api.castle.io/).to_timeout
    end
    it do
      expect do
        api.request('authenticate', user_id: '1234')
      end.to raise_error(Castle::RequestError)
    end
  end

  describe 'handles non-OK response code' do
    before do
      stub_request(:any, /api.castle.io/).to_return(status: 400)
    end
    it 'handles non-OK response code' do
      expect do
        api.request('authenticate', user_id: '1234')
      end.to raise_error(Castle::BadRequestError)
    end
  end

  describe 'handles custom API endpoint' do
    before do
      stub_request(:any, /new.herokuapp.com/)
      Castle.config.api_endpoint = api_endpoint
    end
    it do
      api.request('authenticate', user_id: '1234')
      path = "#{api_endpoint.gsub(/new/, ':secret@new')}/authenticate"
      assert_requested :post, path, times: 1
    end
  end
end

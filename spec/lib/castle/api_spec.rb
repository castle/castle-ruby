# frozen_string_literal: true

require 'spec_helper'

describe Castle::API do
  let(:api) { Castle::API.new('abcd', '1.2.3.4', '{}') }

  it 'handles timeout' do
    stub_request(:any, /api.castle.io/).to_timeout
    expect do
      api.request('authenticate', user_id: '1234')
    end.to raise_error(Castle::RequestError)
  end

  it 'handles non-OK response code' do
    stub_request(:any, /api.castle.io/).to_return(status: 400)
    expect do
      api.request('authenticate', user_id: '1234')
    end.to raise_error(Castle::BadRequestError)
  end

  it 'handles custom API endpoint' do
    stub_request(:any, /new.herokuapp.com/)

    api_endpoint = 'http://new.herokuapp.com:3000/v2'
    Castle.config.api_endpoint = api_endpoint
    # uri = URI(api_endpoint)

    api.request('authenticate', user_id: '1234')
    assert_requested :post,
                     "#{api_endpoint.gsub(/new/, ':secret@new')}/authenticate",
                     times: 1
  end
end

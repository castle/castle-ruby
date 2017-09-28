# frozen_string_literal: true

describe Castle::API do
  let(:api) { described_class.new('X-Castle-Client-Id' => 'abcd', 'X-Castle-Ip' => '1.2.3.4') }
  let(:command) { Castle::Command.new('authenticate', '1234', :post) }
  let(:result_headers) do
    { 'Accept' => '*/*',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent' => 'Ruby', 'X-Castle-Client-Id' => 'abcd',
      'X-Castle-Ip' => '1.2.3.4' }
  end

  describe 'handles timeout' do
    before do
      stub_request(:any, /api.castle.io/).to_timeout
    end
    it do
      expect do
        api.request(command)
      end.to raise_error(Castle::RequestError)
    end
  end

  describe 'handles non-OK response code' do
    before do
      stub_request(:any, /api.castle.io/).to_return(status: 400)
    end
    it do
      expect do
        api.request(command)
      end.to raise_error(Castle::BadRequestError)
    end
  end

  describe 'handles query request' do
    before do
      stub_request(:any, /api.castle.io/)
    end
    it do
      api.request_query('review/1')
      path = "https://api.castle.io/v1/review/1"
      assert_requested :get, path, times: 1, headers: result_headers
    end
  end

  describe 'handles missing configuration' do
    before do
      allow(Castle.config).to receive(:api_secret).and_return('')
    end
    it do
      expect do
        api.request(command)
      end.to raise_error(Castle::ConfigurationError)
    end
  end
end

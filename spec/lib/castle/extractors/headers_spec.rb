# frozen_string_literal: true

describe Castle::Extractors::Headers do
  subject(:headers) { described_class.new(formatted_headers).call }

  let(:formatted_headers) { Castle::HeaderFilter.new(request).call }
  let(:client_id) { 'abcd' }
  let(:env) do
    Rack::MockRequest.env_for(
      '/',
      'Action-Dispatch.request.content-Type' => 'application/json',
      'HTTP_AUTHORIZATION' => 'Basic 123456',
      'HTTP_COOKIE' => "__cid=#{client_id};other=efgh",
      'HTTP_OK' => 'OK',
      'HTTP_ACCEPT' => 'application/json',
      'HTTP_X_FORWARDED_FOR' => '1.2.3.4',
      'HTTP_USER_AGENT' => 'Mozilla 1234',
      'TEST' => '1'
    )
  end
  let(:request) { Rack::Request.new(env) }

  after do
    Castle.config.whitelisted = %w[]
    Castle.config.blacklisted = %w[]
  end

  context 'when whitelist is not set in the configuration' do
    let(:result) do
      {
        'Accept' => 'application/json',
        'Authorization' => true,
        'Cookie' => true,
        'Content-Length' => '0',
        'Ok' => 'OK',
        'User-Agent' => 'Mozilla 1234',
        'X-Forwarded-For' => '1.2.3.4'
      }
    end

    it { expect(headers).to eq(result) }
  end

  context 'when whitelist is set in the configuration' do
    before { Castle.config.whitelisted = %w[Accept OK] }

    let(:result) do
      {
        'Accept' => 'application/json',
        'Authorization' => true,
        'Cookie' => true,
        'Content-Length' => true,
        'Ok' => 'OK',
        'User-Agent' => 'Mozilla 1234',
        'X-Forwarded-For' => true
      }
    end

    it { expect(headers).to eq(result) }
  end

  context 'when blacklist is set in the configuration' do
    context 'with a User-Agent' do
      let(:result) do
        {
          'Accept' => 'application/json',
          'Authorization' => true,
          'Cookie' => true,
          'Content-Length' => '0',
          'Ok' => 'OK',
          'User-Agent' => 'Mozilla 1234',
          'X-Forwarded-For' => '1.2.3.4'
        }
      end

      before { Castle.config.blacklisted = %w[User-Agent] }

      it { expect(headers).to eq(result) }
    end

    context 'with a different header' do
      let(:result) do
        {
          'Accept' => true,
          'Authorization' => true,
          'Cookie' => true,
          'Content-Length' => '0',
          'Ok' => 'OK',
          'User-Agent' => 'Mozilla 1234',
          'X-Forwarded-For' => '1.2.3.4'
        }
      end

      before { Castle.config.blacklisted = %w[Accept] }

      it { expect(headers).to eq(result) }
    end
  end

  context 'when a header is both whitelisted and blacklisted' do
    before do
      Castle.config.whitelisted = %w[Accept]
      Castle.config.blacklisted = %w[Accept]
    end

    it do
      expect(headers['Accept']).to eq(true)
    end
  end
end

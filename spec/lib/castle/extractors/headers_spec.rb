# frozen_string_literal: true

describe Castle::Extractors::Headers do
  subject(:headers) { described_class.new(request).call }

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
      'TEST' => '1',
    )
  end
  let(:request) { Rack::Request.new(env) }

  context 'when whitelist is not set in the configuration' do
    it do
      is_expected.to eq(
                       'Accept' => 'application/json',
                       'Authorization' => true,
                       'Cookie' => true,
                       'Content-Length' => '0',
                       'Ok' => 'OK',
                       'User-Agent' => 'Mozilla 1234',
                       'X-Forwarded-For' => '1.2.3.4'
                     )
    end
  end

  context 'when whitelist is set in the configuration' do
    before { Castle.config.whitelisted = %w[Accept OK] }

    it do
      is_expected.to eq(
                       'Accept' => 'application/json',
                       'Authorization' => true,
                       'Cookie' => true,
                       'Content-Length' => true,
                       'Ok' => 'OK',
                       'User-Agent' => 'Mozilla 1234',
                       'X-Forwarded-For' => true
                     )
    end
  end

  context 'when blacklist is set in the configuration' do
    context 'and includes User-Agent' do
      before { Castle.config.blacklisted = %w[User-Agent] }

      it do
        is_expected.to eq(
                         'Accept' => 'application/json',
                         'Authorization' => true,
                         'Cookie' => true,
                         'Content-Length' => '0',
                         'Ok' => 'OK',
                         'User-Agent' => 'Mozilla 1234',
                         'X-Forwarded-For' => '1.2.3.4'
                       )
      end
    end

    context 'and includes a different header' do
      before { Castle.config.blacklisted = %w[Accept] }

      it do
        is_expected.to eq(
                         'Accept' => true,
                         'Authorization' => true,
                         'Cookie' => true,
                         'Content-Length' => '0',
                         'Ok' => 'OK',
                         'User-Agent' => 'Mozilla 1234',
                         'X-Forwarded-For' => '1.2.3.4'
                       )
      end
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

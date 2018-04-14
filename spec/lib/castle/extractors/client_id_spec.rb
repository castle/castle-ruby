# frozen_string_literal: true

describe Castle::Extractors::ClientId do
  subject(:extractor) { described_class.new(request, cookies) }

  let(:client_id_cookie) { 'abcd' }
  let(:client_id_header) { 'abcde' }
  let(:cookies) { request.cookies }
  let(:request) { Rack::Request.new(env) }
  let(:env) do
    Rack::MockRequest.env_for('/', headers)
  end

  context 'with client_id' do
    let(:headers) do
      {
        'HTTP_X_FORWARDED_FOR' => '1.2.3.4',
        'HTTP_COOKIE' => "__cid=#{client_id_cookie};other=efgh"
      }
    end

    it do
      expect(extractor.call).to eql(client_id_cookie)
    end
  end

  context 'with X-Castle-Client-Id header' do
    let(:headers) do
      {
        'HTTP_X_FORWARDED_FOR' => '1.2.3.4',
        'HTTP_X_CASTLE_CLIENT_ID' => client_id_header
      }
    end

    it 'appends the client_id' do
      expect(extractor.call).to eql(client_id_header)
    end
  end

  context 'when cookies undefined' do
    let(:cookies) { nil }
    let(:headers) { {} }

    it do
      expect(extractor.call).to eql('')
    end
  end

  context 'with X-Castle-Client-Id header and cookies client' do
    let(:headers) do
      {
        'HTTP_X_FORWARDED_FOR' => '1.2.3.4',
        'HTTP_X_CASTLE_CLIENT_ID' => client_id_header,
        'HTTP_COOKIE' => "__cid=#{client_id_cookie};other=efgh"
      }
    end

    it 'appends the client_id' do
      expect(extractor.call).to eql(client_id_header)
    end
  end
end

# frozen_string_literal: true

describe Castle::Fingerprint::Extract do
  subject(:extractor) { described_class.new(formatted_headers, cookies) }

  let(:formatted_headers) { Castle::Headers::Filter.new(request).call }
  let(:fingerprint_cookie) { 'abcd' }
  let(:fingerprint_header) { 'abcde' }
  let(:cookies) { request.cookies }
  let(:request) { Rack::Request.new(env) }
  let(:env) { Rack::MockRequest.env_for('/', headers) }

  context 'with fingerprint' do
    let(:headers) do
      {
        'HTTP_X_FORWARDED_FOR' => '1.2.3.4',
        'HTTP_COOKIE' => "__cid=#{fingerprint_cookie};other=efgh"
      }
    end

    it { expect(extractor.call).to eql(fingerprint_cookie) }
  end

  context 'with X-Castle-Client-Id header' do
    let(:headers) do
      { 'HTTP_X_FORWARDED_FOR' => '1.2.3.4', 'HTTP_X_CASTLE_CLIENT_ID' => fingerprint_header }
    end

    it 'appends the fingerprint' do
      expect(extractor.call).to eql(fingerprint_header)
    end
  end

  context 'when cookies undefined' do
    let(:cookies) { nil }
    let(:headers) { {} }

    it { expect(extractor.call).to eql('') }
  end

  context 'with X-Castle-Client-Id header and cookies client' do
    let(:headers) do
      {
        'HTTP_X_FORWARDED_FOR' => '1.2.3.4',
        'HTTP_X_CASTLE_CLIENT_ID' => fingerprint_header,
        'HTTP_COOKIE' => "__cid=#{fingerprint_cookie};other=efgh"
      }
    end

    it 'appends the fingerprint' do
      expect(extractor.call).to eql(fingerprint_header)
    end
  end
end

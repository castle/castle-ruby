# frozen_string_literal: true

describe Castle::Extractors::Headers do
  subject(:extractor) { described_class.new(request) }

  let(:client_id) { 'abcd' }
  let(:env) do
    Rack::MockRequest.env_for('/',
                              'HTTP_X_FORWARDED_FOR' => '1.2.3.4',
                              'HTTP_OK' => 'OK',
                              'TEST' => '1',
                              'HTTP_COOKIE' => "__cid=#{client_id};other=efgh")
  end
  let(:request) { Rack::Request.new(env) }

  describe 'extract http headers with whitelisted and blacklisted support' do
    before do
      Castle.config.whitelisted += ['TEST']
    end
    it do
      expect(extractor.call).to eql(
        'Test' => '1', 'Ok' => true, 'Rack.version' => true,
        'Rack.input' => true, 'Rack.errors' => true, 'Rack.multithread' => true,
        'Rack.multiprocess' => true, 'Rack.run-Once' => true, 'Request-Method' => true,
        'Server-Name' => true, 'Server-Port' => true, 'Query-String' => true,
        'Path-Info' => true, 'Rack.url-Scheme' => true, 'Https' => true,
        'Script-Name' => true, 'Content-Length' => true, 'X-Forwarded-For' => '1.2.3.4',
        'Cookie' => true
      )
    end
  end
end

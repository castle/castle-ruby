# frozen_string_literal: true

require 'spec_helper'

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
        'X-Forwarded-For' => '1.2.3.4', 'Test' => '1'
      )
    end
  end
end

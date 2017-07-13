# frozen_string_literal: true

require 'spec_helper'

describe Castle::Extractors::Cookie do
  subject(:extractor) { described_class.new(request) }

  let(:client_id) { 'abcd' }
  let(:env) do
    Rack::MockRequest.env_for('/',
                              'HTTP_X_FORWARDED_FOR' => '1.2.3.4',
                              'HTTP_COOKIE' => "__cid=#{client_id};other=efgh")
  end
  let(:request) { Rack::Request.new(env) }

  describe 'cookie' do
    it do
      expect(extractor.extract(nil, '__cid')).to eql(client_id)
    end
  end
end

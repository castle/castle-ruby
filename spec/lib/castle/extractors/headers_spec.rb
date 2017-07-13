# frozen_string_literal: true

require 'spec_helper'

describe Castle::Extractors::Headers do
  subject(:extractor) { described_class.new(request) }

  let(:client_id) { 'abcd' }
  let(:env) do
    Rack::MockRequest.env_for('/',
                              'HTTP_X_FORWARDED_FOR' => '1.2.3.4',
                              'HTTP_TEST' => '2',
                              'TEST' => '1',
                              'HTTP_COOKIE' => "__cid=#{client_id};other=efgh")
  end
  let(:request) { Rack::Request.new(env) }

  describe 'header should extract http headers but skip cookies related' do
    it do
      expect(extractor.extract).to eql(
        '{"X-Forwarded-For":"1.2.3.4","Test":"2"}'
      )
    end
  end
end

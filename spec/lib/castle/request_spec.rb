# frozen_string_literal: true

require 'spec_helper'

describe Castle::Request do
  let(:headers) { { 'SAMPLE-HEADER' => '1' } }
  let(:api_secret) { Castle.config.api_secret }
  subject do
    described_class.new(headers)
  end

  describe 'build' do
    let(:path) { 'endpoint' }
    let(:params) { { user_id: 1 } }

    context 'get' do
      let(:request) { subject.build_query(path) }
      it do
        expect(request.body).to be_nil
        expect(request.method).to eql('GET')
        expect(request.path).to eql('/v1/endpoint')
        expect(request.to_hash['sample-header']).to eql(['1'])
        expect(request.to_hash['authorization'][0]).to match(/Basic \w/)
      end
    end

    context 'post' do
      let(:request) { subject.build(path, params, :post) }
      it do
        expect(request.body).to be_eql('{"user_id":1}')
        expect(request.method).to eql('POST')
        expect(request.path).to eql('/v1/endpoint')
        expect(request.to_hash['sample-header']).to eql(['1'])
        expect(request.to_hash['authorization'][0]).to match(/Basic \w/)
      end
    end
  end
end

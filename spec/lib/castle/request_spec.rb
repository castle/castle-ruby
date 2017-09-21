# frozen_string_literal: true

require 'spec_helper'

describe Castle::Request do
  subject do
    described_class.new(headers)
  end

  let(:headers) { { 'SAMPLE-HEADER' => '1' } }
  let(:api_secret) { Castle.config.api_secret }

  describe 'build' do
    let(:path) { 'endpoint' }
    let(:params) { { user_id: 1 } }

    context 'get' do
      let(:request) { subject.build_query(path) }

      it { expect(request.body).to be_nil }
      it { expect(request.method).to eql('GET') }
      it { expect(request.path).to eql('/v1/endpoint') }
      it { expect(request.to_hash['sample-header']).to eql(['1']) }
      it { expect(request.to_hash['authorization'][0]).to match(/Basic \w/) }
    end

    context 'post' do
      let(:request) { subject.build(path, params, :post) }

      it { expect(request.body).to be_eql('{"user_id":1}') }
      it { expect(request.method).to eql('POST') }
      it { expect(request.path).to eql('/v1/endpoint') }
      it { expect(request.to_hash['sample-header']).to eql(['1']) }
      it { expect(request.to_hash['authorization'][0]).to match(/Basic \w/) }

      context 'with non-UTF-8 charaters' do
        let(:params) { { name: "\xC4" } }

        it { expect(request.body).to eq '{"name":"�"}' }
      end
    end
  end
end

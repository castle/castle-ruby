# frozen_string_literal: true

require 'spec_helper'

describe Castle::Headers do
  subject do
    described_class.new
  end

  before do
    allow(Castle.config).to receive(:source_header).and_return('web')
    allow(subject).to receive(:version).and_return('2.2.0')
  end

  let(:ip) { '1.1.1.1' }
  let(:castle_headers) { 'headers' }
  let(:client_id) { 'some_id' }

  describe 'prepare' do
    let(:prepared_headers) do
      subject.prepare(client_id, ip, castle_headers)
    end

    shared_examples 'for_header' do |header, value|
      let(:header) { header }
      it "has header #{header}" do
        expect(prepared_headers[header]).to eql(value)
      end
    end
    it_should_behave_like 'for_header', 'Content-Type', 'application/json'
    it_should_behave_like 'for_header', 'X-Castle-Cookie-Id', 'some_id'
    it_should_behave_like 'for_header', 'X-Castle-Ip', '1.1.1.1'
    it_should_behave_like 'for_header', 'X-Castle-Headers', 'headers'
    it_should_behave_like 'for_header', 'X-Castle-Source', 'web'
    it_should_behave_like 'for_header',
                          'User-Agent',
                          'Castle/v1 RubyBindings/2.2.0'

    describe 'X-Castle-Client-User-Agent' do
      let(:header) { 'X-Castle-Client-User-Agent' }
      let(:prepared_header_parsed) { JSON.parse(prepared_headers[header]) }

      before do
        allow(Castle::Uname).to receive(:fetch).and_return('name')
      end

      it do
        expect(prepared_header_parsed['bindings_version']).to eql('2.2.0')
        expect(prepared_header_parsed).to include('lang')
        expect(prepared_header_parsed).to include('lang_version')
        expect(prepared_header_parsed).to include('platform')
        expect(prepared_header_parsed).to include('publisher')
        expect(prepared_header_parsed['uname']).to eql('name')
      end
    end

    context 'missing' do
      shared_examples 'for_missing_header' do |header|
        let(:header) { header }
        it "it missing header #{header}" do
          expect(prepared_headers.key?(header)).to be_falsey
        end
      end

      context 'ip' do
        let(:ip) { nil }
        it_should_behave_like 'for_missing_header', 'X-Castle-Ip'
      end

      context 'client_id' do
        let(:client_id) { nil }
        it_should_behave_like 'for_missing_header', 'X-Castle-Cookie-Id'
      end

      context 'castle headers' do
        let(:castle_headers) { nil }
        it_should_behave_like 'for_missing_header', 'X-Castle-Headers'
      end
    end
  end
end

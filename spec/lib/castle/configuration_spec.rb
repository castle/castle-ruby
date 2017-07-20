# frozen_string_literal: true

require 'spec_helper'

describe Castle::Configuration do
  subject(:config) do
    described_class.new
  end

  describe 'api_endpoint' do
    context 'env' do
      let(:value) { 50.0 }

      before do
        allow(ENV).to receive(:fetch).with(
          'CASTLE_API_ENDPOINT', 'https://api.castle.io/v1'
        ).and_return('https://new.herokuapp.com')
        allow(ENV).to receive(:fetch).with(
          'CASTLE_API_SECRET', ''
        ).and_call_original
      end

      it do
        expect(config.api_endpoint).to be_eql(URI('https://new.herokuapp.com'))
      end
    end

    it do
      expect(config.api_endpoint).to be_eql(URI('https://api.castle.io/v1'))
    end
  end

  describe 'api_secret' do
    context 'env' do
      before do
        allow(ENV).to receive(:fetch).with(
          'CASTLE_API_ENDPOINT', 'https://api.castle.io/v1'
        ).and_call_original
        allow(ENV).to receive(:fetch).with(
          'CASTLE_API_SECRET', ''
        ).and_return('secret_key')
      end

      it do
        expect(config.api_secret).to be_eql('secret_key')
      end
    end

    context 'setter' do
      let(:value) { 'new_secret' }

      before do
        config.api_secret = value
      end
      it do
        expect(config.api_secret).to be_eql(value)
      end
    end

    it do
      expect(config.api_secret).to be_eql('')
    end
  end

  describe 'request_timeout' do
    it do
      expect(config.request_timeout).to be_eql(30.0)
    end

    context 'setter' do
      let(:value) { 50.0 }

      before do
        config.request_timeout = value
      end
      it do
        expect(config.request_timeout).to be_eql(value)
      end
    end
  end

  describe 'source_header' do
    it do
      expect(config.source_header).to be_eql(nil)
    end

    context 'setter' do
      let(:value) { 'header' }

      before do
        config.source_header = value
      end
      it do
        expect(config.source_header).to be_eql(value)
      end
    end
  end

  describe 'whitelisted' do
    it do
      expect(config.whitelisted.size).to be_eql(11)
    end

    context 'setter' do
      before do
        config.whitelisted = ['header']
      end
      it do
        expect(config.whitelisted).to be_eql(['Header'])
      end
    end

    context 'appending' do
      before do
        config.whitelisted += ['header']
      end
      it { expect(config.whitelisted).to be_include('Header') }
      it { expect(config.whitelisted.size).to be_eql(12) }
    end
  end

  describe 'blacklisted' do
    it do
      expect(config.blacklisted.size).to be_eql(1)
    end

    context 'setter' do
      before do
        config.blacklisted = ['header']
      end
      it do
        expect(config.blacklisted).to be_eql(['Header'])
      end
    end

    context 'appending' do
      before do
        config.blacklisted += ['header']
      end
      it { expect(config.blacklisted).to be_include('Header') }
      it { expect(config.blacklisted.size).to be_eql(2) }
    end
  end
end

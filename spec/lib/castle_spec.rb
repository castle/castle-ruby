# frozen_string_literal: true

require 'spec_helper'

describe Castle do
  subject(:castle) { described_class }

  describe 'config' do
    it do
      expect(castle.config).to be_kind_of(Castle::Configuration)
    end
  end

  describe 'api_secret setter' do
    let(:value) { 'new_secret' }

    before do
      castle.api_secret = value
    end
    it do
      expect(castle.config.api_secret).to be_eql(value)
    end
  end

  describe 'configure' do
    let(:value) { 'new_secret' }
    let(:timeout) { 60 }

    shared_examples 'config_setup' do
      it { expect(castle.config.api_secret).to be_eql(value) }
      it { expect(castle.config.request_timeout).to be_eql(timeout) }
    end

    context 'by block' do
      before do
        castle.configure do |config|
          config.api_secret = value
          config.request_timeout = timeout
        end
      end
      it_behaves_like 'config_setup'
    end

    context 'by options' do
      before do
        castle.configure(request_timeout: timeout,
                         api_secret: value)
      end
      it_behaves_like 'config_setup'
    end

    context 'by block and options' do
      before do
        castle.configure(request_timeout: timeout) do |config|
          config.api_secret = value
        end
      end
      it_behaves_like 'config_setup'
    end
  end

  describe 'configure wrongly' do
    let(:value) { 'new_secret' }

    it do
      expect do
        castle.configure do |config|
          config.wrong_config = value
        end
      end.to raise_error(Castle::ConfigurationError)
    end
  end
end

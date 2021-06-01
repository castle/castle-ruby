# frozen_string_literal: true

describe Castle do
  subject(:castle) { described_class }

  describe 'config' do
    it { expect(castle.config).to be_kind_of(Castle::Configuration) }
  end

  describe 'api_secret setter' do
    let(:value) { 'new_secret' }

    before { castle.api_secret = value }

    it { expect(castle.config.api_secret).to be_eql(value) }
  end

  describe 'configure' do
    let(:value) { 'new_secret' }
    let(:timeout) { 60 }

    shared_examples 'config_setup' do
      it { expect(castle.config.api_secret).to be_eql(value) }
      it { expect(castle.config.request_timeout).to be_eql(timeout) }
    end

    context 'with block' do
      before do
        castle.configure do |config|
          config.api_secret = value
          config.request_timeout = timeout
        end
      end

      it_behaves_like 'config_setup'
    end

    context 'with options' do
      before { castle.configure(request_timeout: timeout, api_secret: value) }

      it_behaves_like 'config_setup'
    end

    context 'with block and options' do
      before { castle.configure(request_timeout: timeout) { |config| config.api_secret = value } }

      it_behaves_like 'config_setup'
    end
  end

  describe 'configure wrongly' do
    let(:value) { 'new_secret' }

    it do
      expect { castle.configure { |config| config.wrong_config = value } }.to raise_error(
        Castle::ConfigurationError
      )
    end
  end
end

# frozen_string_literal: true

describe Castle::Configuration do
  subject(:config) do
    described_class.new
  end

  describe 'host' do
    context 'with default' do
      it { expect(config.host).to be_eql('api.castle.io') }
    end

    context 'with setter' do
      before { config.host = 'api.castle.dev' }

      it { expect(config.host).to be_eql('api.castle.dev') }
    end
  end

  describe 'post' do
    context 'with default' do
      it { expect(config.port).to be_eql(443) }
    end

    context 'with setter' do
      before { config.port = 3001 }

      it { expect(config.port).to be_eql(3001) }
    end
  end

  describe 'api_secret' do
    context 'with env' do
      before do
        allow(ENV).to receive(:fetch).with(
          'CASTLE_API_SECRET', ''
        ).and_return('secret_key')
      end

      it do
        expect(config.api_secret).to be_eql('secret_key')
      end
    end

    context 'with setter' do
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
      expect(config.request_timeout).to be_eql(500)
    end

    context 'with setter' do
      let(:value) { 50.0 }

      before do
        config.request_timeout = value
      end
      it do
        expect(config.request_timeout).to be_eql(value)
      end
    end
  end

  describe 'whitelisted' do
    it do
      expect(config.whitelisted.size).to be_eql(13)
    end

    context 'with setter' do
      before do
        config.whitelisted = ['header']
      end
      it do
        expect(config.whitelisted).to be_eql(['Header'])
      end
    end

    context 'when appending' do
      before do
        config.whitelisted += ['header']
      end
      it { expect(config.whitelisted).to be_include('Header') }
      it { expect(config.whitelisted.size).to be_eql(14) }
    end
  end

  describe 'blacklisted' do
    it do
      expect(config.blacklisted.size).to be_eql(1)
    end

    context 'with setter' do
      before do
        config.blacklisted = ['header']
      end
      it do
        expect(config.blacklisted).to be_eql(['Header'])
      end
    end

    context 'when appending' do
      before do
        config.blacklisted += ['header']
      end
      it { expect(config.blacklisted).to be_include('Header') }
      it { expect(config.blacklisted.size).to be_eql(2) }
    end
  end

  describe 'failover_strategy' do
    it do
      expect(config.failover_strategy).to be_eql(:allow)
    end

    context 'with setter' do
      before do
        config.failover_strategy = :deny
      end
      it do
        expect(config.failover_strategy).to be_eql(:deny)
      end
    end

    context 'when broken' do
      it do
        expect do
          config.failover_strategy = :unicorn
        end.to raise_error(Castle::ConfigurationError)
      end
    end
  end
end

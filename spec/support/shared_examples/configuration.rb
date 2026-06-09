# frozen_string_literal: true

shared_examples 'configuration_host' do
  describe 'host' do
    context 'with default' do
      it { expect(config.base_url.host).to eql('api.castle.io') }
    end

    context 'with setter' do
      before { config.base_url = 'http://api.castle.dev/v2' }

      it { expect(config.base_url.host).to eql('api.castle.dev') }
    end
  end
end

shared_examples 'configuration_request_timeout' do
  describe 'request_timeout' do
    it { expect(config.request_timeout).to be(1000) }

    context 'with setter' do
      let(:value) { 50.0 }

      before { config.request_timeout = value }

      it { expect(config.request_timeout).to eql(value) }
    end
  end
end

shared_examples 'configuration_allowlisted' do
  describe 'allowlisted' do
    it { expect(config.allowlisted.size).to be(0) }

    context 'with setter' do
      before { config.allowlisted = ['header'] }

      it { expect(config.allowlisted).to eql(['Header']) }
    end
  end
end

shared_examples 'configuration_denylisted' do
  describe 'denylisted' do
    it { expect(config.denylisted.size).to be(0) }

    context 'with setter' do
      before { config.denylisted = ['header'] }

      it { expect(config.denylisted).to eql(['Header']) }
    end
  end
end

shared_examples 'configuration_failover_strategy' do
  describe 'failover_strategy' do
    it { expect(config.failover_strategy).to eql(Castle::Failover::Strategy::ALLOW) }

    context 'with setter' do
      before { config.failover_strategy = Castle::Failover::Strategy::DENY }

      it { expect(config.failover_strategy).to eql(Castle::Failover::Strategy::DENY) }
    end

    context 'when broken' do
      it { expect { config.failover_strategy = :unicorn }.to raise_error(Castle::ConfigurationError) }
    end
  end
end

shared_examples 'configuration_api_secret' do
  describe 'api_secret' do
    context 'with default' do
      before { config.reset }

      it { expect(config.api_secret).to eql('') }
    end

    context 'with setter' do
      let(:value) { 'new_secret' }

      before { config.api_secret = value }

      it { expect(config.api_secret).to eql(value) }
    end
  end
end

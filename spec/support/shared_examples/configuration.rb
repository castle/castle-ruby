# frozen_string_literal: true

shared_examples 'configuration_host' do
  describe 'host' do
    context 'with default' do
      it { expect(config.base_url.host).to be_eql('api.castle.io') }
    end

    context 'with setter' do
      before { config.base_url = 'http://api.castle.dev/v2' }

      it { expect(config.base_url.host).to be_eql('api.castle.dev') }
    end
  end
end

shared_examples 'configuration_request_timeout' do
  describe 'request_timeout' do
    it { expect(config.request_timeout).to be_eql(1000) }

    context 'with setter' do
      let(:value) { 50.0 }

      before { config.request_timeout = value }

      it { expect(config.request_timeout).to be_eql(value) }
    end
  end
end

shared_examples 'configuration_allowlisted' do
  describe 'allowlisted' do
    it { expect(config.allowlisted.size).to be_eql(0) }

    context 'with setter' do
      before { config.allowlisted = ['header'] }

      it { expect(config.allowlisted).to be_eql(['Header']) }
    end
  end
end

shared_examples 'configuration_denylisted' do
  describe 'denylisted' do
    it { expect(config.denylisted.size).to be_eql(0) }

    context 'with setter' do
      before { config.denylisted = ['header'] }

      it { expect(config.denylisted).to be_eql(['Header']) }
    end
  end
end

shared_examples 'configuration_failover_strategy' do
  describe 'failover_strategy' do
    it { expect(config.failover_strategy).to be_eql(Castle::Failover::Strategy::ALLOW) }

    context 'with setter' do
      context 'as symbol' do
        before { config.failover_strategy = Castle::Failover::Strategy::DENY }

        it { expect(config.failover_strategy).to be_eql(Castle::Failover::Strategy::DENY) }
      end

      context 'as proc' do
        before { config.failover_strategy = -> { Castle::Failover::Strategy::DENY } }

        it { expect(config.failover_strategy).to be_eql(Castle::Failover::Strategy::DENY) }
      end
    end

    context 'when broken' do
      context 'as symbol' do
        it do
          expect { config.failover_strategy = :unicorn }.to raise_error(Castle::ConfigurationError)
        end
      end

      context 'as proc' do
        before { config.failover_strategy = -> { :jabberwocky } }

        it { expect { config.failover_strategy }.to raise_error(Castle::ConfigurationError) }
      end
    end
  end
end

shared_examples 'configuration_api_secret' do
  describe 'api_secret' do
    context 'with env' do
      let(:secret_key_env) { 'secret_key_env' }
      let(:secret_key) { 'secret_key' }

      before do
        allow(ENV).to receive(:fetch).with('CASTLE_API_SECRET', '').and_return(secret_key_env)
        config.reset
      end

      it { expect(config.api_secret).to be_eql(secret_key_env) }

      context 'when key is overwritten' do
        before { config.api_secret = secret_key }

        it { expect(config.api_secret).to be_eql(secret_key) }
      end
    end

    context 'with setter' do
      let(:value) { 'new_secret' }

      before { config.api_secret = value }

      it { expect(config.api_secret).to be_eql(value) }
    end
  end
end

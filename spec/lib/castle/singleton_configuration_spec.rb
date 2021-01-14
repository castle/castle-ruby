# frozen_string_literal: true

describe Castle::SingletonConfiguration do
  subject(:config) do
    described_class.instance
  end

  it_behaves_like 'configuration_host'
  it_behaves_like 'configuration_request_timeout'
  it_behaves_like 'configuration_allowlisted'
  it_behaves_like 'configuration_denylisted'
  it_behaves_like 'configuration_failover_strategy'
  it_behaves_like 'configuration_api_secret'

  it do
    expect(config.api_secret).to be_eql('secret')
  end
end

# frozen_string_literal: true

describe Castle::Configuration do
  subject(:config) do
    described_class.new
  end

  it_behaves_like 'configuration_host'
  it_behaves_like 'configuration_request_timeout'
  it_behaves_like 'configuration_allowlisted'
  it_behaves_like 'configuration_denylisted'
  it_behaves_like 'configuration_failover_strategy'
  it_behaves_like 'configuration_api_secret'

  it do
    expect(config.api_secret).to be_eql('')
  end
end

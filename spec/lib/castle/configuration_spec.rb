# frozen_string_literal: true

RSpec.describe Castle::Configuration do
  subject(:config) { described_class.new }

  it_behaves_like 'configuration_host'
  it_behaves_like 'configuration_request_timeout'
  it_behaves_like 'configuration_allowlisted'
  it_behaves_like 'configuration_denylisted'
  it_behaves_like 'configuration_failover_strategy'
  it_behaves_like 'configuration_api_secret'

  it { expect(config.api_secret).to eql('') }
end

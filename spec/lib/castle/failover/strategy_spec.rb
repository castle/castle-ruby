# frozen_string_literal: true

RSpec.describe Castle::Failover::Strategy do
  subject(:strategy) { described_class }

  it { expect(strategy::ALLOW).to be(:allow) }
  it { expect(strategy::DENY).to be(:deny) }
  it { expect(strategy::CHALLENGE).to be(:challenge) }
  it { expect(strategy::THROW).to be(:throw) }

  it { expect(Castle::Failover::STRATEGIES).to eql(%i[allow deny challenge throw]) }
end

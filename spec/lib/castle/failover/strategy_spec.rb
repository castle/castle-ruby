# frozen_string_literal: true

describe Castle::Failover::Strategy do
  subject(:strategy) { described_class }

  it { expect(strategy::ALLOW).to be_eql(:allow) }
  it { expect(strategy::DENY).to be_eql(:deny) }
  it { expect(strategy::CHALLENGE).to be_eql(:challenge) }
  it { expect(strategy::THROW).to be_eql(:throw) }

  it { expect(Castle::Failover::STRATEGIES).to be_eql(%i[allow deny challenge throw]) }
end

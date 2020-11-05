# frozen_string_literal: true

describe Castle::Verdict do
  subject(:verdict) { described_class }

  it { expect(verdict::ALLOW).to be_eql('allow') }
  it { expect(verdict::DENY).to be_eql('deny') }
  it { expect(verdict::CHALLENGE).to be_eql('challenge') }
end

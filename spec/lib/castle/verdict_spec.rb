# frozen_string_literal: true

describe Castle::Verdict do
  subject(:verdict) { described_class }

  it { expect(verdict::ALLOW).to eql('allow') }
  it { expect(verdict::DENY).to eql('deny') }
  it { expect(verdict::CHALLENGE).to eql('challenge') }
end

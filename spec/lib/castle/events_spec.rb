# frozen_string_literal: true

describe Castle::Events do
  it { expect(described_class::LOGIN_SUCCEEDED).to eq('$login.succeeded') }
end

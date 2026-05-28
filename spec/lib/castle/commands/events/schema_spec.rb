# frozen_string_literal: true

RSpec.describe Castle::Commands::Events::Schema do
  describe '.build' do
    subject(:command) { described_class.build }

    it { expect(command.method).to be(:get) }
    it { expect(command.path).to eql('events/schema') }
    it { expect(command.data).to be_nil }
  end
end

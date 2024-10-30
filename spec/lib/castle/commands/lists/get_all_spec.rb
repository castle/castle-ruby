# frozen_string_literal: true

describe Castle::Commands::Lists::GetAll do
  describe '.build' do
    subject(:command) { described_class.build }

    it { expect(command.method).to be(:get) }
    it { expect(command.path).to eql('lists') }
    it { expect(command.data).to be_nil }
  end
end

# frozen_string_literal: true

describe Castle::Commands::List::Delete do
  describe '.build' do
    subject(:command) { described_class.build(options) }

    let(:options) { { list_id: 'list_id' } }

    context 'with valid options' do
      it { expect(command.method).to be(:delete) }
      it { expect(command.path).to eql('lists/list_id') }
      it { expect(command.data).to be_nil }
    end

    context 'without list_id' do
      let(:options) { {} }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end
  end
end

# frozen_string_literal: true

RSpec.describe Castle::Commands::ListItems::Get do
  describe '.build' do
    subject(:command) { described_class.build(options) }

    context 'with valid options' do
      let(:options) { { list_id: 'list_id', list_item_id: 'list_item_id'} }

      it { expect(command.method).to be(:get) }
      it { expect(command.path).to eql('lists/list_id/items/list_item_id') }
      it { expect(command.data).to be_nil }
    end

    context 'with invalid options' do
      let(:options) { { list_id: 'list_id' } }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end
  end
end

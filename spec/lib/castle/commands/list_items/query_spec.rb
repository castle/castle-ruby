# frozen_string_literal: true

RSpec.describe Castle::Commands::ListItems::Query do
  describe '.build' do
    subject(:command) { described_class.build(options) }

    context 'with valid options' do
      let(:options) { { list_id: 'list_id', filters: [{ field: 'primary_value', op: '$eq', value: 'test'}]} }

      it { expect(command.method).to be(:post) }
      it { expect(command.path).to eql('lists/list_id/items/query') }
      it { expect(command.data).to eql(options.except(:list_id)) }
    end

    context 'with invalid filters' do
      let(:options) { { list_id: 'list_id', filters: [{ field: 'primary_field', op: '$eq' }]} }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end

    context 'with no list_id' do
      let(:options) { { filters: [{ field: 'primary_field', op: '$eq', value: 'test' }]} }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end
  end
end

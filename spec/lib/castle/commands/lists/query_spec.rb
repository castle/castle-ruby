# frozen_string_literal: true

RSpec.describe Castle::Commands::Lists::Query do
  describe '.build' do
    subject(:command) { described_class.build(options) }

    context 'with valid options' do
      let(:options) { { filters: [{ field: 'primary_field', op: '$eq', value: 'test' }]} }

      it { expect(command.method).to be(:post) }
      it { expect(command.path).to eql('lists/query') }
      it { expect(command.data).to eq(options.except(:list_id)) }
    end

    context 'with invalid filters' do
      let(:options) { { filters: [{ field: 'primary_field', op: '$eq' }]} }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end

    context 'with invalid sort' do
      let(:options) { { sort: { field: 'primary_field' } } }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end
  end
end

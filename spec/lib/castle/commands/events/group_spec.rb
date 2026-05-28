# frozen_string_literal: true

RSpec.describe Castle::Commands::Events::Group do
  describe '.build' do
    subject(:command) { described_class.build(options) }

    context 'with valid options' do
      let(:options) { { filters: [{ field: 'user.id', op: '$eq', value: 'u-42' }] } }

      it { expect(command.method).to be(:post) }
      it { expect(command.path).to eql('events/group') }
      it { expect(command.data).to eq(options) }
    end

    context 'with invalid filters' do
      let(:options) { { filters: [{ field: 'user.id', op: '$eq' }] } }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end

    context 'with invalid sort' do
      let(:options) { { sort: { field: 'created_at' } } }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end

    context 'with valid sort' do
      let(:options) { { sort: { field: 'created_at', order: '$desc' } } }

      it { expect(command.method).to be(:post) }
      it { expect(command.path).to eql('events/group') }
    end
  end
end

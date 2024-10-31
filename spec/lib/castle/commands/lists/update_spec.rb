# frozen_string_literal: true

describe Castle::Commands::Lists::Update do
  describe '.build' do
    subject(:command) { described_class.build(options) }

    context 'with valid options' do
      let(:options) do
        {
          list_id: 'list_id',
          name: 'name',
          description: 'description',
          color: '$yellow',
          default_item_archivation_time: 6000
        }
      end

      it { expect(command.method).to be(:put) }
      it { expect(command.path).to eql('lists/list_id') }
      it { expect(command.data).to eql(options.except(:list_id)) }
    end

    context 'without list_id' do
      let(:options) { { name: 'name' } }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end
  end
end

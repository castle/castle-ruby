# frozen_string_literal: true

RSpec.describe Castle::Commands::ListItems::CreateBatch do
  describe '.build' do
    subject(:command) { described_class.build(options) }

    let(:items) do
      [
        { primary_value: 'a@example.com', author: { type: '$other', identifier: 'me' } },
        { primary_value: 'b@example.com', author: { type: '$other', identifier: 'me' } }
      ]
    end
    let(:options) { { list_id: '123', items: items } }

    context 'with valid options' do
      it { expect(command.method).to be(:post) }
      it { expect(command.path).to eql('lists/123/items/batch') }
      it { expect(command.data).to eql(items: items) }
    end

    context 'without list_id' do
      let(:options) { { items: items } }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end

    context 'without items' do
      let(:options) { { list_id: '123' } }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end
  end
end

# frozen_string_literal: true

describe Castle::Commands::ListItems::Create do
  describe '.build' do
    subject(:command) { described_class.build(options) }

    context 'with valid options' do
      let(:author) { { type: '$other', identifier: 'some value' } }
      let(:options) { { list_id: 'list_id', author: author, primary_value: 'some value' } }

      it { expect(command.method).to be(:post) }
      it { expect(command.path).to eql('lists/list_id/items') }
      it { expect(command.data).to eql(options.except(:list_id)) }
    end

    context 'with invalid options' do
      let(:options) { { list_id: 'list_id' } }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end
  end
end

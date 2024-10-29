# frozen_string_literal: true

describe Castle::Commands::ListItem::Create do
  describe '.build' do
    subject(:command) { described_class.build(options) }

    let(:author) { { type: '$other', identifier: 'some value' } }
    let(:options) { { list_id: 'list_id', author: author, primary_value: 'some value' } }

    it { expect(command.method).to be(:post) }
    it { expect(command.path).to eql('lists/list_id/items') }
    it { expect(command.data).to eql(options.except(:list_id)) }
  end
end

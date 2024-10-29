# frozen_string_literal: true
describe Castle::Commands::ListItem::Get do
  describe '.build' do
    subject(:command) { described_class.build(options) }

    let(:options) { { list_id: 'list_id', list_item_id: 'list_item_id'} }

    it { expect(command.method).to be(:get) }
    it { expect(command.path).to eql('lists/list_id/items/list_item_id') }
    it { expect(command.data).to be_nil }
  end
end

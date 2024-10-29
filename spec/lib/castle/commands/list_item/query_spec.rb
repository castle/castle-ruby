# frozen_string_literal: true
describe Castle::Commands::ListItem::Query do
  describe '.build' do
    subject(:command) { described_class.build(options) }

    let(:options) { { list_id: 'list_id', filters: [{ field: 'primary_value', op: '$eq', value: 'test'}]} }

    it { expect(command.method).to be(:post) }
    it { expect(command.path).to eql('lists/list_id/items/query') }
    it { expect(command.data).to eql(options) }
  end
end

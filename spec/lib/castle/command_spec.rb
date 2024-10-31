# frozen_string_literal: true

RSpec.describe Castle::Command do
  subject(:command) { described_class.new('go', { id: '1' }, :post) }

  it { expect(command.path).to eql('go') }
  it { expect(command.data).to eql(id: '1') }
  it { expect(command.method).to be(:post) }
end

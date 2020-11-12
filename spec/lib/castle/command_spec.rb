# frozen_string_literal: true

describe Castle::Command do
  subject(:command) { described_class.new('go', { id: '1' }, :post) }

  it { expect(command.path).to be_eql('go') }
  it { expect(command.data).to be_eql(id: '1') }
  it { expect(command.method_name).to be_eql(:post) }
end

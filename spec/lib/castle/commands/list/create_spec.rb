# frozen_string_literal: true

describe Castle::Commands::List::Create do
  describe '.build' do
    subject(:command) { described_class.build(options) }

    let(:options) { { name: 'list_name', color: '$green', primary_field: 'user.email' } }

    context 'with valid options' do
      it { expect(command.method).to be(:post) }
      it { expect(command.path).to eql('lists') }
      it { expect(command.data).to eql(options) }
    end

    context 'without name' do
      let(:options) { { color: '$green', primary_field: 'user.email' } }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end

    context 'without color' do
      let(:options) { { name: 'list_name', primary_field: 'user.email' } }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end

    context 'without primary_field' do
      let(:options) { { name: 'list_name', color: '$green' } }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end
  end
end

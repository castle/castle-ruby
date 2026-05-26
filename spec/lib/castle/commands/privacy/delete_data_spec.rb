# frozen_string_literal: true

RSpec.describe Castle::Commands::Privacy::DeleteData do
  describe '.build' do
    subject(:command) { described_class.build(options) }

    context 'with $id identifier' do
      let(:options) { { identifier: 'user_42', identifier_type: '$id' } }

      it { expect(command.method).to be(:delete) }
      it { expect(command.path).to eql('privacy/users') }
      it { expect(command.data).to eql(options) }
    end

    context 'with $email identifier' do
      let(:options) { { identifier: 'rhea@example.org', identifier_type: '$email' } }

      it { expect(command.data).to eql(options) }
    end

    context 'when identifier is missing' do
      let(:options) { { identifier_type: '$id' } }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end

    context 'when identifier_type is missing' do
      let(:options) { { identifier: 'user_42' } }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end
  end
end

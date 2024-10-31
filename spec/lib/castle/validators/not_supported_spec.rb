# frozen_string_literal: true

RSpec.describe Castle::Validators::NotSupported do
  describe '#call' do
    subject(:call) { described_class.call({ first: 1 }, keys) }

    context 'when keys is present' do
      let(:keys) { %i[first second] }

      it { expect { call }.to raise_error(Castle::InvalidParametersError, 'first is/are not supported') }
    end

    context 'when key is not present' do
      let(:keys) { %i[second third] }

      it { expect { call }.not_to raise_error }
    end
  end
end

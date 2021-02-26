# frozen_string_literal: true

describe Castle::Validators::Present do
  describe '#call' do
    subject(:call) { described_class.call({ first: 1, second: '2', invalid: '' }, keys) }

    context 'when keys is not present' do
      let(:keys) { %i[second third] }

      it do
        expect do
          call
        end.to raise_error(Castle::InvalidParametersError, 'third is missing or empty')
      end
    end

    context 'when keys is empty' do
      let(:keys) { %i[second invalid] }

      it do
        expect do
          call
        end.to raise_error(Castle::InvalidParametersError, 'invalid is missing or empty')
      end
    end

    context 'when key is present' do
      let(:keys) { %i[first second] }

      it { expect { call }.not_to raise_error }
    end
  end
end

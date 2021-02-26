# frozen_string_literal: true

describe Castle::Utils::CleanInvalidChars do
  describe '::call' do
    subject { described_class.call(input) }

    context 'when input is a string' do
      let(:input) { '1234' }

      it { is_expected.to eq input }
    end

    context 'when input is an array' do
      let(:input) { [1, 2, 3, '4'] }

      it { is_expected.to eq input }
    end

    context 'when input is a hash' do
      let(:input) { { user_id: 1 } }

      it { is_expected.to eq input }
    end

    context 'when input is nil' do
      let(:input) { nil }

      it { is_expected.to eq input }
    end

    context 'when input is a nested hash' do
      let(:input) { { user: { id: 1 } } }

      it { is_expected.to eq input }
    end

    context 'with invalid UTF-8 characters' do
      context 'when input is a hash' do
        let(:input) { { user_id: "inv\xC4lid" } }

        it { is_expected.to eq(user_id: 'inv�lid') }
      end

      context 'when input is a nested hash' do
        let(:input) { { user: { id: "inv\xC4lid" } } }

        it { is_expected.to eq(user: { id: 'inv�lid' }) }
      end

      context 'when input is an array of hashes' do
        let(:input) { [{ user: "inv\xC4lid" }] * 2 }

        it { is_expected.to eq([{ user: 'inv�lid' }, { user: 'inv�lid' }]) }
      end

      context 'when input is an array' do
        let(:input) { ["inv\xC4lid"] * 2 }

        it { is_expected.to eq(['inv�lid', 'inv�lid']) }
      end

      context 'when input is a hash with array in key' do
        let(:input) { { items: ["inv\xC4lid"] * 2 } }

        it { is_expected.to eq(items: ['inv�lid', 'inv�lid']) }
      end
    end
  end
end

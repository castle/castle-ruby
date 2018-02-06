# frozen_string_literal: true

describe Castle::Utils do
  let(:nested_strings) { { 'a' => { 'b' => { 'c' => 3 } } } }
  let(:nested_symbols) { { a: { b: { c: 3 } } } }
  let(:nested_mixed) { { 'a' => { b: { 'c' => 3 } } } }
  let(:string_array_of_hashes) { { 'a' => [{ 'b' => 2 }, { 'c' => 3 }, 4] } }
  let(:symbol_array_of_hashes) { { a: [{ b: 2 }, { c: 3 }, 4] } }
  let(:mixed_array_of_hashes) { { a: [{ b: 2 }, { 'c' => 3 }, 4] } }

  describe '#deep_symbolize_keys' do
    subject { described_class.deep_symbolize_keys(hash) }

    context 'when nested_symbols' do
      let(:hash) { nested_symbols }

      it { is_expected.to eq(nested_symbols) }
    end

    context 'when nested_strings' do
      let(:hash) { nested_strings }

      it { is_expected.to eq(nested_symbols) }
    end

    context 'when nested_mixed' do
      let(:hash) { nested_mixed }

      it { is_expected.to eq(nested_symbols) }
    end

    context 'when string_array_of_hashes' do
      let(:hash) { string_array_of_hashes }

      it { is_expected.to eq(symbol_array_of_hashes) }
    end

    context 'when symbol_array_of_hashes' do
      let(:hash) { symbol_array_of_hashes }

      it { is_expected.to eq(symbol_array_of_hashes) }
    end

    context 'when mixed_array_of_hashes' do
      let(:hash) { mixed_array_of_hashes }

      it { is_expected.to eq(symbol_array_of_hashes) }
    end
  end

  describe '#deep_symbolize_keys' do
    subject { described_class.deep_symbolize_keys!(Castle::Utils::Cloner.call(hash)) }

    context 'when nested_symbols' do
      let(:hash) { nested_symbols }

      it { is_expected.to eq(nested_symbols) }
    end

    context 'when nested_strings' do
      let(:hash) { nested_strings }

      it { is_expected.to eq(nested_symbols) }
    end

    context 'when nested_mixed' do
      let(:hash) { nested_mixed }

      it { is_expected.to eq(nested_symbols) }
    end

    context 'when string_array_of_hashes' do
      let(:hash) { string_array_of_hashes }

      it { is_expected.to eq(symbol_array_of_hashes) }
    end

    context 'when symbol_array_of_hashes' do
      let(:hash) { symbol_array_of_hashes }

      it { is_expected.to eq(symbol_array_of_hashes) }
    end

    context 'when mixed_array_of_hashes' do
      let(:hash) { mixed_array_of_hashes }

      it { is_expected.to eq(symbol_array_of_hashes) }
    end
  end

  describe '::replace_invalid_characters' do
    subject { described_class.replace_invalid_characters(input) }

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

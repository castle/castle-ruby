# frozen_string_literal: true

describe Castle::Utils::DeepSymbolizeKeys do
  let(:nested_strings) { { 'a' => { 'b' => { 'c' => 3 } } } }
  let(:nested_symbols) { { a: { b: { c: 3 } } } }
  let(:nested_mixed) { { 'a' => { b: { 'c' => 3 } } } }
  let(:string_array_of_hashes) { { 'a' => [{ 'b' => 2 }, { 'c' => 3 }, 4] } }
  let(:symbol_array_of_hashes) { { a: [{ b: 2 }, { c: 3 }, 4] } }
  let(:mixed_array_of_hashes) { { a: [{ b: 2 }, { 'c' => 3 }, 4] } }

  describe '::call' do
    subject { described_class.call(hash) }

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
end

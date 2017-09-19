# frozen_string_literal: true

require 'spec_helper'

describe Castle::Utils do
  let(:nested_strings) { { 'a' => { 'b' => { 'c' => 3 } } } }
  let(:nested_symbols) { { a: { b: { c: 3 } } } }
  let(:nested_mixed) { { 'a' => { b: { 'c' => 3 } } } }
  let(:string_array_of_hashes) { { 'a' => [{ 'b' => 2 }, { 'c' => 3 }, 4] } }
  let(:symbol_array_of_hashes) { { a: [{ b: 2 }, { c: 3 }, 4] } }
  let(:mixed_array_of_hashes) { { a: [{ b: 2 }, { 'c' => 3 }, 4] } }

  context '#deep_symbolize_keys' do
    subject { described_class.deep_symbolize_keys(hash) }

    context 'nested_symbols' do
      let(:hash) { nested_symbols }

      it { is_expected.to eq(nested_symbols) }
    end

    context 'nested_strings' do
      let(:hash) { nested_strings }

      it { is_expected.to eq(nested_symbols) }
    end

    context 'nested_mixed' do
      let(:hash) { nested_mixed }

      it { is_expected.to eq(nested_symbols) }
    end

    context 'string_array_of_hashes' do
      let(:hash) { string_array_of_hashes }

      it { is_expected.to eq(symbol_array_of_hashes) }
    end

    context 'symbol_array_of_hashes' do
      let(:hash) { symbol_array_of_hashes }

      it { is_expected.to eq(symbol_array_of_hashes) }
    end

    context 'mixed_array_of_hashes' do
      let(:hash) { mixed_array_of_hashes }

      it { is_expected.to eq(symbol_array_of_hashes) }
    end
  end

  context '#deep_symbolize_keys' do
    subject { described_class.deep_symbolize_keys!(Castle::Utils::Cloner.call(hash)) }

    context 'nested_symbols' do
      let(:hash) { nested_symbols }

      it { is_expected.to eq(nested_symbols) }
    end

    context 'nested_strings' do
      let(:hash) { nested_strings }

      it { is_expected.to eq(nested_symbols) }
    end

    context 'nested_mixed' do
      let(:hash) { nested_mixed }

      it { is_expected.to eq(nested_symbols) }
    end

    context 'string_array_of_hashes' do
      let(:hash) { string_array_of_hashes }

      it { is_expected.to eq(symbol_array_of_hashes) }
    end

    context 'symbol_array_of_hashes' do
      let(:hash) { symbol_array_of_hashes }

      it { is_expected.to eq(symbol_array_of_hashes) }
    end

    context 'mixed_array_of_hashes' do
      let(:hash) { mixed_array_of_hashes }

      it { is_expected.to eq(symbol_array_of_hashes) }
    end
  end
end

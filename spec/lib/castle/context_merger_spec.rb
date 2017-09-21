# frozen_string_literal: true

require 'spec_helper'

describe Castle::ContextMerger do
  subject(:command) { described_class.new('go', { id: '1' }, :post) }

  let(:first) { { test: { test1: { c: '4' } } } }

  context '.new' do
    subject(:instance) { described_class.new(first) }

    it { expect(instance.instance_variable_get(:@main_context)).to eq(first) }
    it do
      expect(instance.instance_variable_get(:@main_context).object_id).not_to eq(first.object_id)
    end
  end

  context '#call' do
    subject { described_class.new(first).call(second) }

    let(:result) { { test: { test1: { c: '4', d: '5' } } } }

    context 'symbol keys' do
      let(:second) { { test: { test1: { d: '5' } } } }

      it { is_expected.to eq(result) }
    end

    context 'string keys' do
      let(:second) { { 'test' => { 'test1' => { 'd' => '5' } } } }

      it { is_expected.to eq(result) }
    end
  end
end

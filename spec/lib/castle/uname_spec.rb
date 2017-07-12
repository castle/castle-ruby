# frozen_string_literal: true

require 'spec_helper'

describe Castle::Uname do
  describe 'fetch' do
    context 'successfully' do
      before do
        expect(described_class).to receive(:`).with(
          'uname -a 2>/dev/null'
        ).and_call_original
      end
      it do
        expect(described_class.fetch).to be_kind_of(String)
      end
    end
    context 'successfully' do
      before do
        expect(described_class).to receive(:`).with(
          'uname -a 2>/dev/null'
        ).and_raise(Errno::ENOMEM)
      end
      it do
        expect(described_class.fetch).to eql('uname lookup failed')
      end
    end
  end
end

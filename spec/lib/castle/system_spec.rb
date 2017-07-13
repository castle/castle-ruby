# frozen_string_literal: true

require 'spec_helper'

describe Castle::System do
  describe 'uname' do
    context 'successfully' do
      before do
        allow(described_class).to receive(:`).with(
          'uname -a 2>/dev/null'
        ).and_call_original
      end
      it do
        expect(described_class.uname).to be_kind_of(String)
      end
    end
    context 'successfully' do
      before do
        allow(described_class).to receive(:`).with(
          'uname -a 2>/dev/null'
        ).and_raise(Errno::ENOMEM)
      end
      it do
        expect(described_class.uname).to eql('uname lookup failed')
      end
    end
  end
end

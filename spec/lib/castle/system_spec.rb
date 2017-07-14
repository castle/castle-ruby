# frozen_string_literal: true

require 'spec_helper'

describe Castle::System do
  describe '.uname' do
    subject(:uname) { described_class.uname }

    before { expect(described_class).to receive(:platform) { platform } }

    context 'darwin' do
      let(:platform) { 'x86_64-apple-darwin16.6.0' }

      it { expect { uname }.not_to raise_error }
      it { expect(uname).to be_kind_of(String) }
    end

    context 'linux' do
      let(:platform) { 'x86_64-pc-linux-gnu' }

      it { expect { uname }.not_to raise_error }
      it { expect(uname).to be_kind_of(String) }
    end

    context 'different' do
      let(:platform) { 'different' }

      it { expect { uname }.not_to raise_error }
      it { expect(uname).to be_nil }
    end

    context 'Errno::ENOMEM' do
      let(:platform) { 'x86_64-pc-linux-gnu' }

      before do
        allow(described_class).to receive(:`).with(
          'uname -a 2>/dev/null'
        ).and_raise(Errno::ENOMEM)
      end

      it { expect { uname }.not_to raise_error }
      it { expect(uname).to be_kind_of(String) }
      it { expect(uname).to eql('uname lookup failed') }
    end
  end

  describe '.platform' do
    subject(:platform) { described_class.platform }

    context 'rbconfig' do
      it { expect(platform).to eq(RbConfig::CONFIG['host']) }
    end

    context 'RUBY_PLATFORM' do
      before { stub_const('RbConfig::CONFIG', host: nil) }

      it { expect(platform).to eq(RUBY_PLATFORM) }
    end
  end

  describe '.ruby_version' do
    subject(:ruby_version) { described_class.ruby_version }

    let(:version) do
      "#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})"
    end

    it { expect(ruby_version).to eq(version) }
  end
end

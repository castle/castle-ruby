# frozen_string_literal: true

describe Castle::API::Session do
  describe '#get' do
    it { expect(described_class.get).to eql(described_class.get) }
    it { expect(described_class.get).to eql(described_class.instance.http) }
  end

  describe '#initialize' do
    subject(:session) { described_class.get }

    after do
      described_class.instance.reset
    end

    context 'when ssl false' do
      before do
        Castle.config.url = 'http://localhost:3002'
        described_class.instance.reset
      end

      after do
      end

      it { expect(session).to be_instance_of(Net::HTTP) }
      it { expect(session.address).to eq('localhost') }
      it { expect(session.port).to eq(3002) }
      it { expect(session.use_ssl?).to be false }
      it { expect(session.verify_mode).to be_nil }
    end

    context 'when ssl true' do
      before do
        described_class.instance.reset
      end

      it { expect(session).to be_instance_of(Net::HTTP) }
      it { expect(session.address).to eq(Castle.config.url.host) }
      it { expect(session.port).to eq(Castle.config.url.port) }
      it { expect(session.use_ssl?).to be true }
      it { expect(session.verify_mode).to eq(OpenSSL::SSL::VERIFY_PEER) }
    end
  end
end

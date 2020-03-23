# frozen_string_literal: true

describe Castle::API::SessionSharer do
  describe '#get' do
    it { expect(described_class.get).to eql(described_class.get) }
    it { expect(described_class.get).to eql(described_class.instance.session) }
  end

  describe '#initialize' do
    subject(:session) { described_class.instance.session }

    after do
      Castle::API::SessionSharer.instance.setup
    end

    context 'when ssl false' do
      before do
        Castle.config.host = 'localhost'
        Castle.config.port = 3002
        described_class.instance.setup
      end

      after do
        Castle.config.host = Castle::Configuration::HOST
        Castle.config.port = Castle::Configuration::PORT
      end

      it { expect(session).to be_instance_of(Net::HTTP) }
      it { expect(session.address).to eq('localhost') }
      it { expect(session.port).to eq(3002) }
      it { expect(session.use_ssl?).to be false }
      it { expect(session.verify_mode).to be_nil }
    end

    context 'when ssl true' do
      before do
        described_class.instance.setup
      end

      it { expect(session).to be_instance_of(Net::HTTP) }
      it { expect(session.address).to eq(Castle.config.host) }
      it { expect(session.port).to eq(Castle.config.port) }
      it { expect(session.use_ssl?).to be true }
      it { expect(session.verify_mode).to eq(OpenSSL::SSL::VERIFY_PEER) }
    end
  end
end

# frozen_string_literal: true

describe Castle::API::Session do
  subject(:instance) { described_class.new }

  describe '#initialize' do
    subject(:session) { described_class.new }

    after do
      session.reset
    end

    context 'when ssl false' do
      before do
        Castle.config.host = 'localhost'
        Castle.config.port = 3002
        session.reset
      end

      after do
        Castle.config.host = Castle::Configuration::HOST
        Castle.config.port = Castle::Configuration::PORT
      end

      it { expect(session.http).to be_instance_of(Net::HTTP) }
      it { expect(session.http.address).to eq('localhost') }
      it { expect(session.http.port).to eq(3002) }
      it { expect(session.http.use_ssl?).to be false }
      it { expect(session.http.verify_mode).to be_nil }
    end

    context 'when ssl true' do
      before do
        session.reset
      end

      it { expect(session.http).to be_instance_of(Net::HTTP) }
      it { expect(session.http.address).to eq(Castle.config.host) }
      it { expect(session.http.port).to eq(Castle.config.port) }
      it { expect(session.http.use_ssl?).to be true }
      it { expect(session.http.verify_mode).to eq(OpenSSL::SSL::VERIFY_PEER) }
    end
  end
end

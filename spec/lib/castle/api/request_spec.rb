# frozen_string_literal: true

describe Castle::API::Request do
  describe '#call' do
    subject(:call) { described_class.call(command, api_secret, headers) }

    let(:http) { instance_double('Net::HTTP') }
    let(:request_build) { instance_double('Castle::API::Request::Build') }
    let(:command) { Castle::Commands::Track.new({}).build(event: '$login.succeeded') }
    let(:headers) { {} }
    let(:api_secret) { 'secret' }
    let(:expected_headers) { { 'Content-Type' => 'application/json' } }

    before do
      allow(described_class).to receive(:http).and_return(http)
      allow(http).to receive(:request).with(request_build)
      allow(Castle::API::Request::Build).to receive(:call)
        .with(command, expected_headers, api_secret)
        .and_return(request_build)
      call
    end

    it do
      expect(Castle::API::Request::Build).to have_received(:call)
        .with(command, expected_headers, api_secret)
    end

    it { expect(http).to have_received(:request).with(request_build) }
  end

  describe '#http' do
    subject(:http) { described_class.http }

    context 'when ssl false' do
      before do
        Castle.config.host = 'localhost'
        Castle.config.port = 3002
      end

      after do
        Castle.config.host = Castle::Configuration::HOST
        Castle.config.port = Castle::Configuration::PORT
      end

      it { expect(http).to be_instance_of(Net::HTTP) }
      it { expect(http.address).to eq(Castle.config.host) }
      it { expect(http.port).to eq(Castle.config.port) }
      it { expect(http.use_ssl?).to be false }
      it { expect(http.verify_mode).to be_nil }
    end

    context 'when ssl true' do
      it { expect(http).to be_instance_of(Net::HTTP) }
      it { expect(http.address).to eq(Castle.config.host) }
      it { expect(http.port).to eq(Castle.config.port) }
      it { expect(http.use_ssl?).to be true }
      it { expect(http.verify_mode).to eq(OpenSSL::SSL::VERIFY_PEER) }
    end
  end
end

# frozen_string_literal: true

RSpec.describe Castle::Core::GetConnection do
  describe '.call' do
    subject(:class_call) { described_class.call }

    context 'when ssl false' do
      let(:localhost) { 'localhost' }
      let(:port) { 3002 }
      let(:api_url) { '/test' }

      before do
        Castle.config.base_url = 'http://localhost:3002'

        allow(Net::HTTP).to receive(:new).with(localhost, port).and_call_original
      end

      it do
        class_call

        expect(Net::HTTP).to have_received(:new).with(localhost, port)
      end

      it { expect(class_call).to be_an_instance_of(Net::HTTP) }
    end

    context 'when ssl true' do
      let(:localhost) { 'localhost' }
      let(:port) { 443 }

      before { Castle.config.base_url = 'https://localhost' }

      context 'with block' do
        let(:api_url) { '/test' }
        let(:request) { Net::HTTP::Get.new(api_url) }

        before { allow(Net::HTTP).to receive(:new).with(localhost, port).and_call_original }

        it { expect(class_call).to be_an_instance_of(Net::HTTP) }

        it 'enables SSL with VERIFY_PEER' do
          expect(class_call.use_ssl?).to be true
          expect(class_call.verify_mode).to eq(OpenSSL::SSL::VERIFY_PEER)
        end
      end
    end

    context 'with a per-call config override' do
      let(:custom_config) do
        Castle::Configuration.new.tap do |c|
          c.api_secret = 'custom_secret'
          c.base_url = 'https://custom.castle.example'
          c.request_timeout = 5_000
        end
      end

      it 'uses the host and port from the supplied config, not the singleton' do
        connection = described_class.call(custom_config)
        expect(connection.address).to eq('custom.castle.example')
        expect(connection.port).to eq(443)
      end

      it 'sets both open_timeout and read_timeout from the supplied config' do
        connection = described_class.call(custom_config)
        expect(connection.open_timeout).to eq(5.0)
        expect(connection.read_timeout).to eq(5.0)
      end
    end
  end
end

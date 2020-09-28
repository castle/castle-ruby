# frozen_string_literal: true

describe Castle::API::Session do
  describe '.call' do
    context 'when ssl false' do
      let(:localhost) { 'localhost' }
      let(:port) { 3002 }

      before do
        Castle.config.host = localhost
        Castle.config.port = port
        stub_request(:get, 'localhost:3002/test').to_return(status: 200, body: '{}', headers: {})
      end

      after do
        Castle.config.host = Castle::Configuration::HOST
        Castle.config.port = Castle::Configuration::PORT
      end

      context 'with block' do
        let(:api_url) { '/test' }
        let(:request) { Net::HTTP::Get.new(api_url) }

        before do
          allow(Net::HTTP)
            .to receive(:start)
            .with(localhost, port, { read_timeout: 0.5 })
            .and_call_original

          described_class.call do |http|
            http.request(request)
          end
        end

        it do
          expect(Net::HTTP)
            .to have_received(:start)
            .with(localhost, port, { read_timeout: 0.5 })
        end

        it do
          expect(a_request(:get, 'localhost:3002/test'))
            .to have_been_made.once
        end
      end

      context 'without block' do
        before { described_class.call }

        it do
          expect(a_request(:get, 'localhost:3002/test'))
            .not_to have_been_made
        end
      end
    end

    context 'when ssl true' do
      let(:localhost) { 'localhost' }
      let(:port) { 443 }

      before do
        Castle.config.host = localhost
        Castle.config.port = port
      end

      after do
        Castle.config.host = Castle::Configuration::HOST
        Castle.config.port = Castle::Configuration::PORT
      end

      context 'with block' do
        let(:api_url) { '/test' }
        let(:request) { Net::HTTP::Get.new(api_url) }
        let(:conn_options) do
          { use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_PEER, read_timeout: 0.5 }
        end

        before do
          allow(Net::HTTP)
            .to receive(:start)
            .with(localhost, port, conn_options)

          described_class.call do |http|
            http.request(request)
          end
        end

        it do
          expect(Net::HTTP)
            .to have_received(:start)
            .with(localhost, port, conn_options)
        end
      end
    end
  end
end

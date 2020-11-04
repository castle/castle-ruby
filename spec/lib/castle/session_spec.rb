# frozen_string_literal: true

describe Castle::Session do
  describe '.call' do
    context 'when ssl false' do
      let(:localhost) { 'localhost' }
      let(:port) { 3002 }

      before do
        Castle.config.base_url = 'http://localhost:3002'
        stub_request(:get, 'localhost:3002/test').to_return(status: 200, body: '{}', headers: {})
      end

      context 'with block' do
        let(:api_url) { '/test' }
        let(:request) { Net::HTTP::Get.new(api_url) }

        before do
          allow(Net::HTTP)
            .to receive(:new)
            .with(localhost, port)
            .and_call_original

          described_class.call do |http|
            http.request(request)
          end
        end

        it do
          expect(Net::HTTP)
            .to have_received(:new)
            .with(localhost, port)
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
        Castle.config.base_url = 'https://localhost'
        stub_request(:get, 'https://localhost/test').to_return(status: 200, body: '{}', headers: {})
      end

      context 'with block' do
        let(:api_url) { '/test' }
        let(:request) { Net::HTTP::Get.new(api_url) }

        before do
          allow(Net::HTTP)
            .to receive(:new)
            .with(localhost, port)
            .and_call_original

          allow(Net::HTTP)
            .to receive(:start)

          described_class.call do |http|
            http.request(request)
          end
        end

        it do
          expect(Net::HTTP)
            .to have_received(:new)
            .with(localhost, port)
        end
      end
    end
  end
end

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
      end
    end
  end
end

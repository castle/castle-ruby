# frozen_string_literal: true

# tmp logger for testing
class TmpLogger
  # @param _message [String]
  def info(_message); end
end

describe Castle::Logger do
  subject(:log) do
    described_class.call(message, data)
  end

  let(:message) { 'https://localhost/test:' }
  let(:integration_logger) { TmpLogger.new }
  let(:data) { { a: 1 }.to_json }
  let(:logger_message) { "[CASTLE] #{message} #{data}" }

  before do
    allow(integration_logger).to receive(:info).and_call_original
  end

  describe '.call' do
    context 'without logger' do
      before do
        Castle.config.logger = nil
        log
      end

      it { expect(integration_logger).not_to have_received(:info) }
    end

    context 'with logger' do
      before do
        Castle.config.logger = integration_logger
        log
      end

      it { expect(integration_logger).to have_received(:info).with(logger_message) }
    end
  end
end

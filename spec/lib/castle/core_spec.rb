# frozen_string_literal: true

describe Castle::Core do
  subject(:call) { described_class.call(command) }

  let(:command) { Castle::Commands::Track.new({}).build(event: '$login.succeeded') }

  context 'when request timeouts' do
    before { stub_request(:any, /api.castle.io/).to_timeout }

    it do
      expect do
        call
      end.to raise_error(Castle::RequestError)
    end
  end

  context 'when non-OK response code' do
    before { stub_request(:any, /api.castle.io/).to_return(status: 400) }

    it do
      expect do
        call
      end.to raise_error(Castle::BadRequestError)
    end
  end

  context 'when no api_secret' do
    before { allow(Castle.config).to receive(:api_secret).and_return('') }

    it do
      expect do
        call
      end.to raise_error(Castle::ConfigurationError)
    end
  end
end

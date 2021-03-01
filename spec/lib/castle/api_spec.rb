# frozen_string_literal: true

describe Castle::API do
  subject(:call) { described_class.call(command) }

  let(:command) { Castle::Commands::Track.build(event: '$login') }

  context 'when request timeouts' do
    before { stub_request(:any, /api.castle.io/).to_timeout }

    it { expect { call }.to raise_error(Castle::RequestError) }
  end

  context 'when non-OK response code' do
    before { stub_request(:any, /api.castle.io/).to_return(status: 400) }

    it { expect { call }.to raise_error(Castle::BadRequestError) }
  end

  context 'when no api_secret' do
    before { allow(Castle.config).to receive(:api_secret).and_return('') }

    it { expect { call }.to raise_error(Castle::ConfigurationError) }
  end

  context 'when custom config' do
    let(:config) { Castle::Configuration.new }

    before do
      config.api_secret = 'test'
      stub_request(:any, /api.castle.io/)
    end

    it { expect { call }.not_to raise_error }
  end
end

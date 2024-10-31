# frozen_string_literal: true

RSpec.describe Castle::Core::SendRequest do
  let(:config) { Castle.config }

  describe '#call' do
    let(:command) { Castle::Commands::Track.build(event: '$login.succeeded') }
    let(:headers) { {} }
    let(:request_build) { {} }
    let(:expected_headers) { { 'Content-Type' => 'application/json' } }
    let(:http) { instance_double(Net::HTTP) }

    context 'without http arg provided' do
      subject(:call) { described_class.call(command, headers, nil, config) }

      let(:http) { instance_double(Net::HTTP) }
      let(:command) { Castle::Commands::Track.build(event: '$login.succeeded') }
      let(:headers) { {} }
      let(:request_build) { {} }
      let(:expected_headers) { { 'Content-Type' => 'application/json' } }

      before do
        allow(Castle::Core::GetConnection).to receive(:call).and_return(http)
        allow(http).to receive(:request)
        allow(described_class).to receive(:build).and_return(request_build)
        call
      end

      it { expect(described_class).to have_received(:build).with(command, expected_headers, config) }

      it { expect(http).to have_received(:request).with(request_build) }
    end

    context 'with http arg provided' do
      subject(:call) { described_class.call(command, headers, http, config) }

      before do
        allow(Castle::Core::GetConnection).to receive(:call)
        allow(http).to receive(:request)
        allow(described_class).to receive(:build).and_return(request_build)
        call
      end

      it { expect(Castle::Core::GetConnection).not_to have_received(:call) }

      it { expect(described_class).to have_received(:build).with(command, expected_headers, config) }

      it { expect(http).to have_received(:request).with(request_build) }
    end
  end

  describe '#build' do
    subject(:build) { described_class.build(command, headers, config) }

    let(:headers) { { 'SAMPLE-HEADER' => '1' } }
    let(:api_secret) { 'secret' }

    context 'when post' do
      let(:time) { Time.now.utc.iso8601(3) }
      let(:command) { Castle::Commands::Track.build(event: '$login.succeeded', name: "\xC4") }
      let(:expected_body) { { event: '$login.succeeded', name: '�', context: {}, sent_at: time } }

      before { allow(Castle::Utils::GetTimestamp).to receive(:call).and_return(time) }

      it { expect(build.body).to eql(expected_body.to_json) }
      it { expect(build.method).to eql('POST') }
      it { expect(build.path).to eql("/v1/#{command.path}") }
      it { expect(build.to_hash).to have_key('authorization') }
      it { expect(build.to_hash).to have_key('sample-header') }
      it { expect(build.to_hash['sample-header']).to eql(['1']) }
    end

    context 'when get' do
      let(:time) { Time.now.utc.iso8601(3) }
      let(:command) { Castle::Commands::GetDevice.build(device_token: '1') }
      let(:expected_body) { {} }

      before { allow(Castle::Utils::GetTimestamp).to receive(:call).and_return(time) }

      it { expect(build.body).to eql(expected_body.to_json) }
      it { expect(build.method).to eql('GET') }
      it { expect(build.path).to eql("/v1/#{command.path}") }
    end

    context 'when put' do
      let(:time) { Time.now.utc.iso8601(3) }
      let(:command) { Castle::Commands::ApproveDevice.build(device_token: '1') }
      let(:expected_body) { {} }

      before { allow(Castle::Utils::GetTimestamp).to receive(:call).and_return(time) }

      it { expect(build.body).to eql(expected_body.to_json) }
      it { expect(build.method).to eql('PUT') }
      it { expect(build.path).to eql("/v1/#{command.path}") }
    end
  end
end

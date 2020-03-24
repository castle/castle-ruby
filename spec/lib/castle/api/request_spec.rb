# frozen_string_literal: true

describe Castle::API::Request do
  describe '#call' do
    subject(:call) { described_class.call(command, api_secret, headers) }

    let(:session) { instance_double('Castle::API::Session') }
    let(:http) { instance_double('Net::HTTP') }
    let(:command) { Castle::Commands::Track.new({}).build(event: '$login.succeeded') }
    let(:headers) { {} }
    let(:api_secret) { 'secret' }
    let(:request_build) { {} }
    let(:expected_headers) { { 'Content-Type' => 'application/json' } }

    before do
      allow(Castle::API::Session).to receive(:instance).and_return(session)
      allow(session).to receive(:http).and_return(http)
      allow(http).to receive(:request)
      allow(described_class).to receive(:build).and_return(request_build)
      call
    end

    it do
      expect(described_class).to have_received(:build).with(command, expected_headers, api_secret)
    end

    it { expect(http).to have_received(:request).with(request_build) }
  end

  describe '#build' do
    subject(:build) { described_class.build(command, headers, api_secret) }

    let(:headers) { { 'SAMPLE-HEADER' => '1' } }
    let(:api_secret) { 'secret' }

    context 'when get' do
      let(:command) { Castle::Commands::Review.build(review_id) }
      let(:review_id) { SecureRandom.uuid }

      it { expect(build.body).to be_nil }
      it { expect(build.method).to eql('GET') }
      it { expect(build.path).to eql("/v1/#{command.path}") }
      it { expect(build.to_hash).to have_key('authorization') }
      it { expect(build.to_hash).to have_key('sample-header') }
      it { expect(build.to_hash['sample-header']).to eql(['1']) }
    end

    context 'when post' do
      let(:time) { Time.now.utc.iso8601(3) }
      let(:command) do
        Castle::Commands::Track.new({}).build(event: '$login.succeeded', name: "\xC4")
      end
      let(:expected_body) do
        {
          event: '$login.succeeded',
          name: '�',
          context: {},
          sent_at: time
        }
      end

      before { allow(Castle::Utils::Timestamp).to receive(:call).and_return(time) }

      it { expect(build.body).to be_eql(expected_body.to_json) }
      it { expect(build.method).to eql('POST') }
      it { expect(build.path).to eql("/v1/#{command.path}") }
      it { expect(build.to_hash).to have_key('authorization') }
      it { expect(build.to_hash).to have_key('sample-header') }
      it { expect(build.to_hash['sample-header']).to eql(['1']) }
    end
  end
end

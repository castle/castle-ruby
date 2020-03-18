# frozen_string_literal: true

describe Castle::API::Request::Build do
  subject(:call) { described_class.call(command, headers, api_secret) }

  let(:headers) { { 'SAMPLE-HEADER' => '1' } }
  let(:api_secret) { 'secret' }

  describe 'call' do
    context 'when get' do
      let(:command) { Castle::Commands::Review.build(review_id) }
      let(:review_id) { SecureRandom.uuid }

      it { expect(call.body).to be_nil }
      it { expect(call.method).to eql('GET') }
      it { expect(call.path).to eql("/v1/#{command.path}") }
      it { expect(call.to_hash).to have_key('authorization') }
      it { expect(call.to_hash).to have_key('sample-header') }
      it { expect(call.to_hash['sample-header']).to eql(['1']) }
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

      it { expect(call.body).to be_eql(expected_body.to_json) }
      it { expect(call.method).to eql('POST') }
      it { expect(call.path).to eql("/v1/#{command.path}") }
      it { expect(call.to_hash).to have_key('authorization') }
      it { expect(call.to_hash).to have_key('sample-header') }
      it { expect(call.to_hash['sample-header']).to eql(['1']) }
    end
  end
end

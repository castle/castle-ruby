# frozen_string_literal: true

describe Castle::Headers::Extract do
  subject(:extract_call) { described_class.new(formatted_headers).call }

  let(:formatted_headers) do
    {
      'Content-Length' => '0',
      'Authorization' => 'Basic 123456',
      'Cookie' => '__cid=abcd;other=efgh',
      'Ok' => 'OK',
      'Accept' => 'application/json',
      'X-Forwarded-For' => '1.2.3.4',
      'User-Agent' => 'Mozilla 1234'
    }
  end

  after do
    Castle.config.allowlisted = %w[]
    Castle.config.denylisted = %w[]
  end

  context 'when allowlist is not set in the configuration' do
    let(:result) do
      {
        'Accept' => 'application/json',
        'Authorization' => true,
        'Cookie' => true,
        'Content-Length' => '0',
        'Ok' => 'OK',
        'User-Agent' => 'Mozilla 1234',
        'X-Forwarded-For' => '1.2.3.4'
      }
    end

    it { expect(extract_call).to eq(result) }
  end

  context 'when allowlist is set in the configuration' do
    before { Castle.config.allowlisted = %w[Accept OK] }

    let(:result) do
      {
        'Accept' => 'application/json',
        'Authorization' => true,
        'Cookie' => true,
        'Content-Length' => true,
        'Ok' => 'OK',
        'User-Agent' => 'Mozilla 1234',
        'X-Forwarded-For' => true
      }
    end

    it { expect(extract_call).to eq(result) }
  end

  context 'when denylist is set in the configuration' do
    context 'with a User-Agent' do
      let(:result) do
        {
          'Accept' => 'application/json',
          'Authorization' => true,
          'Cookie' => true,
          'Content-Length' => '0',
          'Ok' => 'OK',
          'User-Agent' => 'Mozilla 1234',
          'X-Forwarded-For' => '1.2.3.4'
        }
      end

      before { Castle.config.denylisted = %w[User-Agent] }

      it { expect(extract_call).to eq(result) }
    end

    context 'with a different header' do
      let(:result) do
        {
          'Accept' => true,
          'Authorization' => true,
          'Cookie' => true,
          'Content-Length' => '0',
          'Ok' => 'OK',
          'User-Agent' => 'Mozilla 1234',
          'X-Forwarded-For' => '1.2.3.4'
        }
      end

      before { Castle.config.denylisted = %w[Accept] }

      it { expect(extract_call).to eq(result) }
    end
  end

  context 'when a header is both allowlisted and denylisted' do
    before do
      Castle.config.allowlisted = %w[Accept]
      Castle.config.denylisted = %w[Accept]
    end

    it { expect(extract_call['Accept']).to eq(true) }
  end
end

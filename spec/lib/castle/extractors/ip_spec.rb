# frozen_string_literal: true

describe Castle::Extractors::IP do
  subject(:extractor) { described_class.new(request) }

  let(:request) { Rack::Request.new(env) }

  describe 'ip' do
    context 'when regular ip' do
      let(:env) {
        Rack::MockRequest.env_for('/',
          'HTTP_X_FORWARDED_FOR' => '1.1.1.1, 1.2.2.2, 1.2.3.5')
      }

      it { expect(extractor.call).to eql('1.2.3.5') }
    end
  end
end

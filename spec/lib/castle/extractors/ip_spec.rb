# frozen_string_literal: true

require 'spec_helper'

describe Castle::Extractors::IP do
  subject(:extractor) { described_class.new(request) }

  let(:request) { Rack::Request.new(env) }

  describe 'ip' do
    let(:env) do
      Rack::MockRequest.env_for('/',
                                'HTTP_X_FORWARDED_FOR' => '1.2.3.4')
    end

    it do
      expect(extractor.call).to eql('1.2.3.4')
    end
  end
end

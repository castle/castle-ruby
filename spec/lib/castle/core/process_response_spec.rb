# frozen_string_literal: true

describe Castle::Core::ProcessResponse do
  describe '#call' do
    subject(:call) { described_class.call(response) }

    context 'when success' do
      let(:response) { OpenStruct.new(body: '{"user":1}', code: 200) }

      it { expect(call).to eql(user: 1) }
    end

    describe 'authenticate' do
      context 'when allow without any additional props' do
        let(:response) { OpenStruct.new(body: '{"action":"allow","user_id":"12345"}', code: 200) }

        it { expect(call).to eql({ action: 'allow', user_id: '12345' }) }
      end

      context 'when allow with additional props' do
        let(:response) { OpenStruct.new(body: '{"action":"allow","user_id":"12345","internal":{}}', code: 200) }

        it { expect(call).to eql({ action: 'allow', user_id: '12345', internal: {} }) }
      end

      context 'when deny without risk policy' do
        let(:response) { OpenStruct.new(body: '{"action":"deny","user_id":"1","device_token":"abc"}', code: 200) }

        it { expect(call).to eql({ action: 'deny', user_id: '1', device_token: 'abc' }) }
      end

      context 'when deny with risk policy' do
        let(:body) do
          '{"action":"deny","user_id":"1","device_token":"abc",
          "risk_policy":{"id":"123","revision_id":"abc","name":"def","type":"bot"}}'
        end
        let(:response) { OpenStruct.new({ body: body, code: 200 }) }

        let(:result) do
          {
            action: 'deny',
            user_id: '1',
            device_token: 'abc',
            risk_policy: {
              id: '123',
              revision_id: 'abc',
              name: 'def',
              type: 'bot'
            }
          }
        end

        it { expect(call).to eql(result) }
      end
    end

    context 'when response empty' do
      let(:response) { OpenStruct.new(body: '', code: 200) }

      it { expect(call).to eql({}) }
    end

    context 'when response nil' do
      let(:response) { OpenStruct.new(code: 200) }

      it { expect(call).to eql({}) }
    end

    context 'when json is malformed' do
      let(:response) { OpenStruct.new(body: '{a', code: 200) }

      it { expect { call }.to raise_error(Castle::ApiError) }
    end
  end

  describe '#verify!' do
    subject(:verify!) { described_class.verify!(response) }

    context 'without error when response is 2xx' do
      let(:response) { OpenStruct.new(code: 200) }

      it { expect { verify! }.not_to raise_error }
    end

    shared_examples 'response_failed' do |code, error|
      let(:response) { OpenStruct.new(code: code) }

      it "fail when response is #{code}" do
        expect { verify! }.to raise_error(error)
      end
    end

    it_behaves_like 'response_failed', '400', Castle::BadRequestError
    it_behaves_like 'response_failed', '401', Castle::UnauthorizedError
    it_behaves_like 'response_failed', '403', Castle::ForbiddenError
    it_behaves_like 'response_failed', '404', Castle::NotFoundError
    it_behaves_like 'response_failed', '419', Castle::UserUnauthorizedError
    it_behaves_like 'response_failed', '422', Castle::InvalidParametersError
    it_behaves_like 'response_failed', '429', Castle::TooManyRequestsError
    it_behaves_like 'response_failed', '499', Castle::ApiError
    it_behaves_like 'response_failed', '500', Castle::InternalServerError
  end
end

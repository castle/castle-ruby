# frozen_string_literal: true

require 'spec_helper'

describe Castle::Response do
  subject(:castle_response) do
    described_class.new(response)
  end

  describe 'initialize' do
    context 'without error when response is 2xx' do
      let(:response) { OpenStruct.new(code: 200) }

      it do
        expect(castle_response).to be_truthy
      end
    end

    shared_examples 'response_failed' do |code, error|
      let(:response) { OpenStruct.new(code: code) }

      it "fail when response is #{code}" do
        expect do
          castle_response
        end.to raise_error(error)
      end
    end

    it_behaves_like 'response_failed', 400, Castle::BadRequestError
    it_behaves_like 'response_failed', 401, Castle::UnauthorizedError
    it_behaves_like 'response_failed', 403, Castle::ForbiddenError
    it_behaves_like 'response_failed', 404, Castle::NotFoundError
    it_behaves_like 'response_failed', 419, Castle::UserUnauthorizedError
    it_behaves_like 'response_failed', 422, Castle::InvalidParametersError
    it_behaves_like 'response_failed', 499, Castle::ApiError
    it_behaves_like 'response_failed', 500, Castle::InternalServerError
  end

  describe 'parse' do
    context 'successfully' do
      let(:response) { OpenStruct.new(body: '{"user":1}', code: 200) }

      it do
        expect(castle_response.parse).to eql(user: 1)
      end
    end
    context 'return empty object when response empty' do
      let(:response) { OpenStruct.new(body: '', code: 200) }

      it do
        expect(castle_response.parse).to eql({})
      end
    end
    context 'return empty object when response nil' do
      let(:response) { OpenStruct.new(code: 200) }

      it do
        expect(castle_response.parse).to eql({})
      end
    end
    context 'fail when json is malformed' do
      let(:response) { OpenStruct.new(body: '{a', code: 200) }

      it do
        expect do
          castle_response.parse
        end.to raise_error(Castle::ApiError)
      end
    end
  end
end

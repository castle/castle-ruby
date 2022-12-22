# frozen_string_literal: true

RSpec.shared_examples_for 'action request' do |action|
  subject(:request_response) { client.send(action.to_sym, options) }

  let(:options) do
    { request_token: request_token, event: event, status: status, user: user, context: context, properties: properties }
  end
  let(:request_token) { '7e51335b-f4bc-4bc7-875d-b713fb61eb23-bf021a3022a1a302' }
  let(:event) { '$login' }
  let(:status) { '$succeeded' }
  let(:user) { { id: '1234', email: 'foobar@mail.com' } }
  let(:properties) { {} }
  let(:request_body) do
    {
      request_token: request_token,
      event: event,
      status: status,
      user: user,
      context: context,
      properties: properties,
      timestamp: time_auto,
      sent_at: time_auto
    }
  end

  context 'when used with symbol keys' do
    it do
      request_response

      assert_requested :post, "https://api.castle.io/v1/#{action}", times: 1 do |req|
        JSON.parse(req.body) == JSON.parse(request_body.to_json)
      end
    end

    context 'when passed timestamp in options and no defined timestamp' do
      let(:client) { client_with_no_timestamp }

      before do
        options[:timestamp] = time_user
        request_body[:timestamp] = time_user

        request_response
      end

      it do
        assert_requested :post, "https://api.castle.io/v1/#{action}", times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
        end
      end
    end

    context 'with client initialized with timestamp' do
      let(:client) { client_with_user_timestamp }

      before do
        request_body[:timestamp] = time_user

        request_response
      end

      it do
        assert_requested :post, "https://api.castle.io/v1/#{action}", times: 1 do |req|
          JSON.parse(req.body) == JSON.parse(request_body.to_json)
        end
      end
    end
  end

  context 'when used with string keys' do
    before { request_response }

    it do
      assert_requested :post, "https://api.castle.io/v1/#{action}", times: 1 do |req|
        JSON.parse(req.body) == JSON.parse(request_body.to_json)
      end
    end
  end

  context 'when tracking enabled' do
    before { request_response }

    it do
      assert_requested :post, "https://api.castle.io/v1/#{action}", times: 1 do |req|
        JSON.parse(req.body) == JSON.parse(request_body.to_json)
      end
    end

    it { expect(request_response[:failover]).to be false }
    it { expect(request_response[:failover_reason]).to be_nil }
  end

  context 'when tracking disabled' do
    before do
      client.disable_tracking
      request_response
    end

    it { assert_not_requested :post, "https://api.castle.io/v1/#{action}" }
    it { expect(request_response[:policy][:action]).to be_eql(Castle::Verdict::ALLOW) }
    it { expect(request_response[:action]).to be_eql(Castle::Verdict::ALLOW) }
    it { expect(request_response[:user_id]).to be_eql('1234') }
    it { expect(request_response[:failover]).to be true }
    it { expect(request_response[:failover_reason]).to be_eql('Castle is set to do not track.') }
  end

  context 'when request with fail' do
    before { allow(Castle::API).to receive(:send_request).and_raise(Castle::RequestError.new(Timeout::Error)) }

    context 'with request error and throw strategy' do
      before { allow(Castle.config).to receive(:failover_strategy).and_return(:throw) }

      it { expect { request_response }.to raise_error(Castle::RequestError) }
    end

    context 'with request error and not throw on eg deny strategy' do
      it { assert_not_requested :post, "https:/:secret@api.castle.io/v1/#{action}" }
      it { expect(request_response[:policy][:action]).to be_eql('allow') }
      it { expect(request_response[:action]).to be_eql('allow') }
      it { expect(request_response[:user_id]).to be_eql('1234') }
      it { expect(request_response[:failover]).to be true }
      it { expect(request_response[:failover_reason]).to be_eql('Castle::RequestError') }
    end
  end

  context 'when request is internal server error' do
    before { allow(Castle::API).to receive(:send_request).and_raise(Castle::InternalServerError) }

    describe 'throw strategy' do
      before { allow(Castle.config).to receive(:failover_strategy).and_return(:throw) }

      it { expect { request_response }.to raise_error(Castle::InternalServerError) }
    end

    describe 'not throw on eg deny strategy' do
      it { assert_not_requested :post, "https:/:secret@api.castle.io/v1/#{action}" }
      it { expect(request_response[:policy][:action]).to be_eql('allow') }
      it { expect(request_response[:action]).to be_eql('allow') }
      it { expect(request_response[:user_id]).to be_eql('1234') }
      it { expect(request_response[:failover]).to be true }
      it { expect(request_response[:failover_reason]).to be_eql('Castle::InternalServerError') }
    end
  end

  context 'when request is 422' do
    describe 'throw InvalidParametersError' do
      let(:response_body) { { type: 'bad_request', message: 'wrong params' }.to_json }
      let(:response_code) { 422 }

      it { expect { request_response }.to raise_error(Castle::InvalidParametersError, 'wrong params') }
    end

    describe 'throw InvalidParametersError for legacy endpoints' do
      let(:response_body) { {}.to_json }
      let(:response_code) { 422 }

      it { expect { request_response }.to raise_error(Castle::InvalidParametersError) }
    end

    describe 'throw InvalidRequestTokenError' do
      let(:response_body) { { type: 'invalid_request_token', message: 'invalid token' }.to_json }
      let(:response_code) { 422 }

      it { expect { request_response }.to raise_error(Castle::InvalidRequestTokenError, 'invalid token') }
    end
  end
end

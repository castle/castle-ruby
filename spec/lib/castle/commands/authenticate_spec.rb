# frozen_string_literal: true

require 'spec_helper'

describe Castle::Commands::Authenticate do
  subject(:instance) { described_class.new(context) }

  let(:context) { { test: { test1: '1' } } }
  let(:default_payload) { { event: '$login.authenticate', user_id: '1234' } }

  describe '.build' do
    subject(:command) { instance.build(payload) }

    context 'no user_id' do
      let(:payload) { { event: '$login.authenticate' } }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end

    context 'no event' do
      let(:payload) { { user_id: '1234' } }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end

    context 'simple merger' do
      let(:payload) { default_payload.merge({ context: { test: { test2: '1' } } }) }
      let(:command_data) do
        default_payload.merge({ context: { test: { test1: '1', test2: '1' } } })
      end

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('authenticate') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'properties' do
      let(:payload) { default_payload.merge({ properties: { test: '1' } }) }
      let(:command_data) do
        default_payload.merge({ properties: { test: '1' }, context: context })
      end

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('authenticate') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'traits' do
      let(:payload) { default_payload.merge({ traits: { test: '1' } }) }
      let(:command_data) do
        default_payload.merge({ traits: { test: '1' }, context: context })
      end

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('authenticate') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'active true' do
      let(:payload) { default_payload.merge({ context: { active: true } }) }
      let(:command_data) do
        default_payload.merge({ context: context.merge(active: true) })
      end

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('authenticate') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'active false' do
      let(:payload) { default_payload.merge({ context: { active: false } }) }
      let(:command_data) do
        default_payload.merge({ context: context.merge(active: false) })
      end

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('authenticate') }
      it { expect(command.data).to be_eql(command_data) }
    end

    context 'active string' do
      let(:payload) { default_payload.merge({ context: { active: 'string' } }) }
      let(:command_data) { default_payload.merge({ context: context }) }

      it { expect(command.method).to be_eql(:post) }
      it { expect(command.path).to be_eql('authenticate') }
      it { expect(command.data).to be_eql(command_data) }
    end
  end
end

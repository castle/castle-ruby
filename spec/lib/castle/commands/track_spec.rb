# frozen_string_literal: true

require 'spec_helper'

describe Castle::Commands::Track do
  subject(:command_builder) { described_class.new(context) }

  describe 'build' do
    let(:context) { { test: { test1: '1' } } }
    let(:command) do
      command_builder.build('approve', user_id: '1234', something: '1234',
                                       properties: { 'pro': 1 }, traits: { sample: 'ok' },
                                       active: 'ok',
                                       context: { test: { test2: '1' } })
    end

    it { expect(command.path).to be_eql('track') }
    it do
      expect(command.data).to be_eql(context: { test: { test1: '1', test2: '1' } },
                                     properties: {  'pro': 1 },
                                     event: 'approve',
                                     user_id: '1234')
    end
    it { expect(command.method).to be_eql(:post) }
  end
end

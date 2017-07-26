# frozen_string_literal: true

require 'spec_helper'

describe Castle::DefaultContext do
  subject { described_class.new(headers, ip) }

  let(:ip) { '1.1.1.1' }
  let(:headers) { { 'Accept-Language' => 'en', 'Remote-Addr' => ip, 'User-Agent' => 'test' } }
  let(:default_context) { subject.call }

  before do
    allow(Castle.config).to receive(:source_header).and_return('web')
    stub_const('Castle::VERSION', '2.2.0')
  end

  it { expect(default_context[:active]).to be_eql(true) }
  it { expect(default_context[:origin]).to be_eql('web') }
  it { expect(default_context[:request][:headers]).to be_eql(headers) }
  it { expect(default_context[:ip]).to be_eql(ip) }
  it { expect(default_context[:library][:name]).to be_eql('castle-rb') }
  it { expect(default_context[:library][:version]).to be_eql('2.2.0') }
  it { expect(default_context[:request][:remoteAddress]).to be_eql(ip) }
  it { expect(default_context[:userAgent]).to be_eql('test') }
end

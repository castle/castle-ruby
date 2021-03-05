# frozen_string_literal: true

describe Castle::Context::GetDefault do
  subject { described_class }

  let(:default_context) { subject.call }
  let(:version) { '2.2.0' }

  before { stub_const('Castle::VERSION', version) }

  it { expect(default_context[:active]).to be_eql(true) }
  it { expect(default_context[:library][:name]).to be_eql('castle-rb') }
  it { expect(default_context[:library][:version]).to be_eql(version) }
end

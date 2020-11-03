# frozen_string_literal: true

describe Castle::Utils::GenerateTimestamp do
  subject(:timestamp) { described_class.call }

  let(:time_string) { '2018-01-10T14:14:24.407Z' }
  let(:time) { Time.parse(time_string) }

  before { Timecop.freeze(time) }

  after { Timecop.return }

  describe '#call' do
    it { expect(timestamp).to eql(time_string) }
  end
end

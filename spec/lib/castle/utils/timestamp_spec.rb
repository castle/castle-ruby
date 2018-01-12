# frozen_string_literal: true

describe Castle::Utils::Timestamp do
  subject { described_class.call }

  let(:time_string) { '2018-01-10T14:14:24.407Z' }
  let(:time) { Time.parse(time_string) }

  before do
    Timecop.freeze(time)
  end

  after do
    Timecop.return
  end

  describe '#call' do
    it do
      is_expected.to eql(time_string)
    end
  end
end

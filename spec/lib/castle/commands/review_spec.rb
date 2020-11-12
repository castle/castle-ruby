# frozen_string_literal: true

describe Castle::Commands::Review do
  subject(:instance) { described_class }

  let(:context) { {} }
  let(:review_id) { '1234' }

  describe '.build' do
    subject(:command) { instance.build(review_id: review_id) }

    context 'without review_id' do
      let(:review_id) { '' }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end

    context 'with review_id' do
      it { expect(command.method_name).to be_eql(:get) }
      it { expect(command.path).to be_eql("reviews/#{review_id}") }
      it { expect(command.data).to be_nil }
    end
  end
end

# frozen_string_literal: true

RSpec.describe Castle::Commands::GetDevicesForUser do
  subject(:instance) { described_class }

  let(:context) { {} }
  let(:user_id) { '1234' }

  describe '.build' do
    subject(:command) { instance.build(user_id: user_id) }

    context 'without user_id' do
      let(:user_id) { '' }

      it { expect { command }.to raise_error(Castle::InvalidParametersError) }
    end

    context 'with user_id' do
      it { expect(command.method).to be(:get) }
      it { expect(command.path).to eql("users/#{user_id}/devices") }
      it { expect(command.data).to be_nil }
    end
  end
end

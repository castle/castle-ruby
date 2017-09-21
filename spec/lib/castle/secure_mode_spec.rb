# frozen_string_literal: true

describe Castle::SecureMode do
  it 'has signature' do
    expect(described_class.signature('test')).to eql(
      '0329a06b62cd16b33eb6792be8c60b158d89a2ee3a876fce9a881ebb488c0914'
    )
  end
end

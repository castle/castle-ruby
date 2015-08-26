describe Castle::Verification do
  it 'extends Castle::Model' do
    instance = Castle::Verification.new
    expect(instance).to be_a Castle::Model
  end
end

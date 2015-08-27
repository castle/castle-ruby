describe Castle::Context do
  it 'extends Castle::Model' do
    instance = Castle::Context.new
    expect(instance).to be_a Castle::Model
  end
end

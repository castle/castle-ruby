describe Castle::Event do
  it 'extends Castle::Model' do
    instance = Castle::Event.new
    expect(instance).to be_a Castle::Model
  end
end

describe Castle::Location do
  it 'extends Castle::Model' do
    instance = Castle::Location.new
    expect(instance).to be_a Castle::Model
  end
end

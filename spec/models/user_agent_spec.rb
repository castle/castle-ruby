describe Castle::UserAgent do
  it 'extends Castle::Model' do
    instance = Castle::UserAgent.new
    expect(instance).to be_a Castle::Model
  end
end

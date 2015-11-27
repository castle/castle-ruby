describe Castle::Authentication do
  it 'extends Castle::Model' do
    instance = Castle::Authentication.new
    expect(instance).to be_a Castle::Model
  end
end

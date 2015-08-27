describe Castle::Account do
  it 'extends Castle::Model' do
    instance = Castle::Account.new
    expect(instance).to be_a Castle::Model
  end
end

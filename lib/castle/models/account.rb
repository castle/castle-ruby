module Castle
  class Account < Model
    def self.fetch
      get('/v1/account')
    end

    def self.update(settings = {})
      put('/v1/account', settings: settings)
    end
  end
end

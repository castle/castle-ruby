module UserbinRails
  class Railtie < Rails::Railtie
    initializer "userbin" do |app|
      app.config.middleware.use "Userbin::Authentication"
    end
  end
end

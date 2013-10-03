require 'userbin/rails/auth_helpers'

module Userbin
  ActiveSupport.on_load(:action_controller) do
    include AuthHelpers
  end

  class Railtie < Rails::Railtie
    initializer "userbin" do |app|
      ActionView::Base.send :include, AuthHelpers
      app.config.middleware.use "Userbin::Authentication"
    end
  end
end

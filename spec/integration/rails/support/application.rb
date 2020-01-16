# frozen_string_literal: true

require 'action_controller/railtie'

class TestApp < Rails::Application
  secrets.secret_token = 'secret_token'
  secrets.secret_key_base = 'secret_key_base'

  config.logger = Logger.new($stdout)
  Rails.logger = config.logger

  routes.draw do
    get '/' => 'home#index'
  end
end

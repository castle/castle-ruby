# frozen_string_literal: true

require 'action_controller/railtie'

class TestApp < Rails::Application
  secrets.secret_token = 'secret_token'
  secrets.secret_key_base = 'secret_key_base'

  config.logger = Logger.new($stdout)
  Rails.logger = config.logger

  routes.draw do
    get '/index1' => 'home#index1'
    get '/index2' => 'home#index2'
    get '/index3' => 'home#index3'
  end
end

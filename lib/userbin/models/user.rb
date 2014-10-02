module Userbin
  class User < Model
    custom_post :import
    instance_post :lock
    instance_post :unlock
    instance_post :enable_mfa
    instance_post :disable_mfa

    has_many :channels
    has_many :events
    has_many :pairings
    has_many :sessions
  end
end

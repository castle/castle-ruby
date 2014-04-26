module Userbin
  class User < Base
    custom_post :authenticate
    custom_post :import
    instance_post :activate
    instance_post :lock
    instance_post :unlock

    has_many :sessions
  end
end

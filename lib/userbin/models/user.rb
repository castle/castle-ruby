module Userbin
  class User < Base
    custom_post :import
    instance_post :lock
    instance_post :unlock

    has_many :sessions
  end
end

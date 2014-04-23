module Userbin
  class User < Base
    custom_post :verify_email
    custom_post :forgot_password
    custom_post :resend_verification
    instance_post :activate
    instance_post :lock
    instance_post :unlock
    instance_post :reset_password

    has_many :sessions
  end
end

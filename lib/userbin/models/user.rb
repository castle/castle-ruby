module Userbin
  class User < Model
    custom_post :import
    instance_post :lock
    instance_post :unlock
    instance_post :enable_mfa
    instance_post :disable_mfa

    has_many :challenges
    has_many :events
    has_many :pairings
    has_many :sessions

    def recovery_codes(params={})
      Userbin::RecoveryCodes.get("/v1/users/#{id}/recovery_codes", params)
    end

    def generate_recovery_codes(params={})
      Userbin::RecoveryCodes.post("/v1/users/#{id}/recovery_codes", params)
    end
  end
end

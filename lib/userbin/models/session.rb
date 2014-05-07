module Userbin
  class Session < Base
    primary_key :token
    instance_post :refresh
    instance_post :verify

    def expired?
      Userbin::JWT.new(token).expired?
    end
  end
end

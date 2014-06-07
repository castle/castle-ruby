module Userbin
  class Session < Base
    primary_key :token
    instance_post :refresh

    def expired?
      Userbin::JWT.new(token).expired?
    end
  end
end

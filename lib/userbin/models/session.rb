module Userbin
  class Session < Base
    instance_post :refresh

    def expired?
      Userbin::JWT.new(id).expired?
    end
  end
end

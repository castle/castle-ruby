module Userbin
  class Session < Model
    instance_post :refresh
  end
end

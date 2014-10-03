module Userbin
  class Challenge < Model
    has_one :pairing
    instance_post :verify
  end
end

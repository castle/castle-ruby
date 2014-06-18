module Userbin
  class Challenge < Model
    has_one :channel
    instance_post :verify
  end
end

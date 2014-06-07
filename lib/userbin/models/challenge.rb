module Userbin
  class Challenge < Base
    has_one :channel
    instance_post :verify
  end
end

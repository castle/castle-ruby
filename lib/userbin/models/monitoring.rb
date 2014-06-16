module Userbin
  class Monitoring < Base
    collection_path '/v1' # Her doesn't accept the empty string
    custom_post :heartbeat
  end
end

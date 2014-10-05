module Userbin
  class Challenge < Model
    collection_path "users/:user_id/challenges"
    has_one :pairing
    instance_post :verify
  end
end

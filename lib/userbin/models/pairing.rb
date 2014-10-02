module Userbin
  class Pairing < Model
    collection_path "users/:user_id/pairings"
    instance_post :verify
    belongs_to :user
  end
end

module Userbin
  class Pairing < Model
    collection_path "users/:user_id/pairings"
    instance_post :verify
    instance_post :default
    belongs_to :user
  end
end

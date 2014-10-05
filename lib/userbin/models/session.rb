module Userbin
  class Session < Model
    collection_path "users/:user_id/sessions"
    instance_post :refresh
  end
end

module Userbin
  class Session < Model
    collection_path "users/:user_id/sessions"
  end
end

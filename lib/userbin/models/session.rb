module Userbin
  class Session < Model
    collection_path "users/:user_id/sessions"
    has_one :context
  end
end

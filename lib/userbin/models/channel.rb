module Userbin
  class Channel < Model
    collection_path "users/:user_id/channels"
    belongs_to :user
  end
end

module Userbin
  class Event < Model
    collection_path "users/:user_id/events"
    belongs_to :user
  end
end

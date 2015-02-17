module Castle
  class Event < Model
    collection_path "users/:user_id/events"
    belongs_to :user
    has_one :context
  end
end

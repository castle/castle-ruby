module Castle
  class Authentication < Model
    has_one :user
    has_one :context

    instance_post :approve
    instance_post :deny
    instance_post :reset
  end
end

module Castle
  class Authentication < Model
    has_one :user
    has_one :context

    instance_post :allow
    instance_post :deny
    instance_post :reset
  end
end

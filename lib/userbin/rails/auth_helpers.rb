module Userbin
  module AuthHelpers
    def userbin_current_user
      local_id = Userbin.current_user.local_id

      if local_id
        user_klass = if Userbin.config.user_model
          Userbin.config.user_model.call
        else
          User
        end
        @current_user ||= user_klass.find(local_id)
      end
    end
  end
end

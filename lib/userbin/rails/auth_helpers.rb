module Userbin
  module AuthHelpers
    def authenticate_user!
      unless user_logged_in?
        env['userbin.unauthenticated'] = true
        render nothing: true
      end
    end

    def current_user
      Userbin.current_user
    end

    def user_logged_in?
      Userbin.user_logged_in?
    end

    def user_signed_in?
      Userbin.user_signed_in?
    end
  end
end

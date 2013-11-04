module Userbin
  module AuthHelpers
    def current_user
      return unless Userbin.authenticated?
      if Userbin.config.current_user
        @current_user ||= Userbin.config.current_user.call(Userbin.current_user)
      else
        raise "Userbin: No method configured for returning 'current_user'"
      end
    end
  end
end

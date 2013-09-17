module Userbin
  class Current
    attr_accessor :token, :expires_at, :user

    def initialize(data)
      if data
        @token = data['id']
        @expires_at = data['expires_at']
        @user = Userbin::User.new(data['user'])
      end
    end

    def authenticated?
      !@user.nil?
    end
  end
end

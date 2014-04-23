module Userbin
  class LoginToken < Token
    accepts_nested_attributes_for :user
  end
end

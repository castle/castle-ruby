module Userbin
  class Token < Base
    has_one :user
  end
end

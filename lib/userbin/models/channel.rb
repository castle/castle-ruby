module Userbin
  class Channel < Model
    has_one :token
  end
end

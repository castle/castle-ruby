require 'her'

module Userbin
  class Model
    include Her::Model
  end

  class User < Model; end

  class Session < Model
    has_one :user

    # Hack to avoid loading a remote user
    def user
      return self['user'] if self['user'].is_a?(User)
      User.new(self['user']) if self['user']
    end

    def authenticated?
      !user.id.nil? rescue false
    end
  end

  class Event < Model
  end
end

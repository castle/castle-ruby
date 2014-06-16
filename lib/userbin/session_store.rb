module Userbin
  class SessionStore
    attr_accessor :key

    class Rack < SessionStore
      def initialize(session)
        @session = session
      end

      def read
        @session[key]
      end

      def write(value)
        @session[key] = value
      end

      def destroy
        @session.delete(key)
      end
    end

  end
end

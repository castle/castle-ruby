module Userbin
  class SessionStore
    class Rack < SessionStore
      def initialize(session)
        @session = session
      end

      def user_id
        @session['userbin.user_id']
      end

      def user_id=(value)
        @session['userbin.user_id'] = value
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

      private

      def key
        "userbin.user.#{user_id}"
      end
    end
  end
end

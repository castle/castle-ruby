module Castle
  class SessionStore
    class Rack < SessionStore
      def initialize(session)
        @session = session
      end

      def user_id
        @session['Castleuser_id']
      end

      def user_id=(value)
        @session['Castleuser_id'] = value
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
        "Castleuser.#{user_id}"
      end
    end
  end
end

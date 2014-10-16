module Userbin
  class TrustedTokenStore
    class Rack < TrustedTokenStore
      def initialize(cookies)
        @cookies = cookies
      end

      def user_id
        @cookies['userbin.user_id']
      end

      def user_id=(value)
        @cookies['userbin.user_id'] = value
      end

      def read
        @cookies[key]
      end

      def write(value)
        @cookies[key] = value
      end

      def destroy
        @cookies.delete(key)
      end

      private

      def key
        "userbin.trusted_device_token.#{user_id}"
      end
    end
  end
end

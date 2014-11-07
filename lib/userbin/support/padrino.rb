require_relative 'cookie_store'

module Padrino
  class Application
    module Userbin
      module Helpers
        def userbin
          store = ::Userbin::CookieStore.new(request, response)
          @userbin ||= ::Userbin::Client.new(request, store)
        end
      end

      def self.registered(app)
        app.helpers Helpers
      end
    end

    register Userbin
  end
end

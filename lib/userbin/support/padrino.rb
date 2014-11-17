require_relative 'cookie_store'

module Padrino
  class Application
    module Userbin
      module Helpers
        def userbin
          @userbin ||= ::Userbin::Client.new(request, response)
        end
      end

      def self.registered(app)
        app.helpers Helpers
      end
    end

    register Userbin
  end
end

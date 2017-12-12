# frozen_string_literal: true

module Padrino
  class Application
    module Castle
      module Helpers
        def castle
          @castle ||= ::Castle::Client.from_request(request)
        end
      end

      def self.registered(app)
        app.helpers Helpers
      end
    end

    register Castle
  end
end

# frozen_string_literal: true

require_relative 'cookie_store'

module Padrino
  class Application
    module Castle
      module Helpers
        def castle
          @castle ||= ::Castle::Client.new(request, response)
        end
      end

      def self.registered(app)
        app.helpers Helpers
      end
    end

    register Castle
  end
end

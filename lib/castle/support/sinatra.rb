# frozen_string_literal: true

require 'sinatra/base'

module Sinatra
  module Castle
    module Helpers
      def castle
        @castle ||= ::Castle::Client.new(request)
      end
    end

    def self.registered(app)
      app.helpers Castle::Helpers
    end
  end

  register Castle
end

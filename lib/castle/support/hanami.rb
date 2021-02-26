# frozen_string_literal: true

module Castle
  module Hanami
    module Action
      def castle
        @castle ||=
          ::Castle::Client.from_request(
            request,
            cookies: (cookies if defined?(cookies))
          )
      end
    end

    def self.included(base)
      base.configure { controller.prepare { include Castle::Hanami::Action } }
    end
  end
end

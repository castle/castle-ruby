# frozen_string_literal: true

module Castle
  module Hanami
    module Action
      def castle
        @castle ||= ::Castle::Client.new(request, (cookies if defined? cookies))
      end
    end

    def self.included(base)
      base.configure do
        controller.prepare do
          include Castle::Hanami::Action
        end
      end
    end
  end
end

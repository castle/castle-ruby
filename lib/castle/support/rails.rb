# frozen_string_literal: true

module Castle
  module CastleClient
    def castle
      @castle ||= request.env['castle'] || Castle::Client.new(request)
    end
  end

  ActiveSupport.on_load(:action_controller) do
    include CastleClient
  end
end

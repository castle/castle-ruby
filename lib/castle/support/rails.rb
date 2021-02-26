# frozen_string_literal: true

module Castle
  module CastleClient
    def castle
      @castle ||= request.env['castle'] || Castle::Client.from_request(request)
    end
  end

  ActiveSupport.on_load(:action_controller) do
    include CastleClient
  end
end

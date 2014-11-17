module Userbin
  module UserbinClient
    def userbin
      @userbin ||= Userbin::Client.new(request, response)
    end
  end

  ActiveSupport.on_load(:action_controller) do
    include UserbinClient
  end
end

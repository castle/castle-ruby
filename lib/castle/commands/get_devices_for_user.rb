# frozen_string_literal: true

module Castle
  module Commands
    # Generates the payload for the GET users/#{user_id}/devices request
    class GetDevicesForUser
      class << self
        # @param options [Hash]
        # @return [Castle::Command]
        def build(options = {})
          Castle::Validators::Present.call(options, %i[user_id])
          Castle::Command.new("users/#{options[:user_id]}/devices", nil, :get)
        end
      end
    end
  end
end

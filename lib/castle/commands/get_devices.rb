# frozen_string_literal: true

module Castle
  module Commands
    # Generated the payload for the GET #{user_id}/devices request
    class GetDevices
      class << self
        # @param options [Hash]
        # @return [Castle::Command]
        def build(options = {})
          Castle::Validators::Present.call(options, %i[user_id])
          Castle::Command.new(
            "#{options[:user_id]}/devices",
            nil,
            :get
          )
        end
      end
    end
  end
end

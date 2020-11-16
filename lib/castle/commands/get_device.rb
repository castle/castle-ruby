# frozen_string_literal: true

module Castle
  module Commands
    # Generated the payload for the GET devices/#{device_token} request
    class GetDevice
      class << self
        # @param options [Hash]
        # @return [Castle::Command]
        def build(options = {})
          Castle::Validators::Present.call(options, %i[device_token])
          Castle::Command.new(
            "devices/#{options[:device_token]}",
            nil,
            :get
          )
        end
      end
    end
  end
end

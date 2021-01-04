# frozen_string_literal: true

module Castle
  module Commands
    # Generates the payload for the PUT devices/#{device_token}/approve request
    class ApproveDevice
      class << self
        # @param options [Hash]
        # @return [Castle::Command]
        def build(options = {})
          Castle::Validators::Present.call(options, %i[device_token])
          Castle::Command.new(
            "devices/#{options[:device_token]}/approve",
            nil,
            :put
          )
        end
      end
    end
  end
end

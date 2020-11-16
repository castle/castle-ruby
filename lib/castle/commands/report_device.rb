# frozen_string_literal: true

module Castle
  module Commands
    # Generated the payload for the PUT devices/#{device_token}/report request
    class ReportDevice
      class << self
        # @param options [Hash]
        # @return [Castle::Command]
        def build(options = {})
          Castle::Validators::Present.call(options, %i[device_token])
          Castle::Command.new(
            "devices/#{options[:device_token]}/report",
            nil,
            :put
          )
        end
      end
    end
  end
end

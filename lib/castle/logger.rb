# frozen_string_literal: true

module Castle
  # module for logger handling
  module Logger
    class << self
      # @param message [String]
      # @param data [String]
      def call(message, data = nil, config: Castle.config)
        logger = config.logger

        return unless logger

        logger.info("[CASTLE] #{message} #{data}".strip)
      end
    end
  end
end

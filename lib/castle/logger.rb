# frozen_string_literal: true

module Castle
  module Logger
    class << self
      def call(message, data = nil)
        logger = Castle.config.logger

        return unless logger

        logger.info("[CASTLE] #{message} #{data}".strip)
      end
    end
  end
end

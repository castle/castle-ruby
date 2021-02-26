# frozen_string_literal: true

module Castle
  module Core
    # Parses a webhook
    module ProcessWebhook
      class << self
        # Checks if webhook is valid
        # @param webhook [Request]
        def call(webhook)
          webhook
            .body
            .read
            .tap do |result|
              raise Castle::ApiError, 'Invalid webhook from Castle API' if result.blank?

              Castle::Logger.call('webhook:', result.to_s)
            end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Castle
  module Core
    # Parses a webhook
    module ProcessWebhook
      class << self
        # Checks if webhook is valid
        # @param webhook [Request]
        # @param config [Castle::Configuration, Castle::SingletonConfiguration, nil]
        # @return [String]
        def call(webhook, config = nil)
          webhook
            .body
            .read
            .tap do |result|
              raise Castle::ApiError, 'Invalid webhook from Castle API' if result.blank?

              Castle::Logger.call('webhook:', result.to_s, config)
            end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Castle
  module Core
    # Parses a webhook
    module ProcessWebhook
      class << self
        # Checks if webhook is valid
        # @param webhook [Request]
        def call(webhook)
          Castle::Logger.call('webhook:', webhook.body.to_s)

          return {} if webhook.body.nil? || webhook.body.empty?

          begin
            JSON.parse(webhook.body, symbolize_names: true)
          rescue JSON::ParserError
            raise Castle::ApiError, 'Invalid webhook from Castle API'
          end
        end
      end
    end
  end
end

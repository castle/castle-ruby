# frozen_string_literal: true

module Castle
  module Core
    # parses webhook
    module ProcessWebhook
      class << self
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

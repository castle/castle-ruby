# frozen_string_literal: true

module Castle
  module Webhooks
    class Verify
      class << self
        def call(webhook)
          expected_signature = compute_signature(webhook)
          signature = webhook.env['X-Castle-Signature']
          verify_signature(signature, expected_signature)

          true
        end

        private

        def compute_signature(webhook)
          user_id = user_id_from_webhook(webhook)
          Castle::SecureMode.signature(user_id)
        end

        def verify_signature(signature, expected_signature)
          return if Castle::Utils::SecureCompare.call(signature, expected_signature)

          raise Castle::WebhookVerificationError, 'Signature not matching the expected signature'
        end

        def user_id_from_webhook(webhook)
          payload = Castle::Core::ProcessWebhook.call(webhook)
          return '' if payload.nil? || payload.empty

          payload&.data&.user_id
        end
      end
    end
  end
end

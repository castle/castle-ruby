# frozen_string_literal: true

module Castle
  module Webhooks
    class Verify
      class << self
        # Checks if incoming webhook is valid
        # @param webhook [Request]
        def call(webhook)
          expected_signature = compute_signature(webhook)
          signature = webhook.env['X-Castle-Signature']
          verify_signature(signature, expected_signature)
        end

        private

        # Computes a webhook signature using provided user_id
        # @param webhook [Request]
        def compute_signature(webhook)
          user_id = user_id_from_webhook(webhook)
          Castle::SecureMode.signature(user_id)
        end

        # Check if the signatures are matching
        # @param signature [String] first signature to be compared
        # @param expected_signature [String] second signature to be compared
        def verify_signature(signature, expected_signature)
          return if Castle::Utils::SecureCompare.call(signature, expected_signature)

          raise Castle::WebhookVerificationError, 'Signature not matching the expected signature'
        end

        # Extracts user_id from webhook
        # @param webhook [Request]
        def user_id_from_webhook(webhook)
          payload = Castle::Core::ProcessWebhook.call(webhook)
          return '' if payload.nil? || payload.empty?

          payload&.data&.user_id
        end
      end
    end
  end
end

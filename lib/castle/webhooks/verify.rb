# frozen_string_literal: true

module Castle
  module Webhooks
    # Verify a webhook
    class Verify
      class << self
        # Checks if webhook is valid
        # @param webhook [Request]
        # @param config [Castle::Configuration, Castle::SingletonConfiguration, nil]
        def call(webhook, config = nil)
          config ||= Castle.config
          expected_signature = compute_signature(webhook, config)
          signature = webhook.env['HTTP_X_CASTLE_SIGNATURE']
          verify_signature(signature, expected_signature)
        end

        private

        # Computes a webhook signature using provided user_id
        # @param webhook [Request]
        # @param config [Castle::Configuration, Castle::SingletonConfiguration]
        # @return [String]
        def compute_signature(webhook, config)
          Base64.encode64(
            OpenSSL::HMAC.digest(
              OpenSSL::Digest.new('sha256'),
              config.api_secret,
              Castle::Core::ProcessWebhook.call(webhook, config)
            )
          ).strip
        end

        # Check if the signatures are matching
        # @param signature [String] first signature to be compared
        # @param expected_signature [String] second signature to be compared
        def verify_signature(signature, expected_signature)
          return if Castle::Utils::SecureCompare.call(signature, expected_signature)

          raise Castle::WebhookVerificationError, 'Signature not matching the expected signature'
        end
      end
    end
  end
end

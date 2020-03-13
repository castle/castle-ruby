# frozen_string_literal: true

module Castle
  module Extractors
    # used for extraction of cookies and headers from the request
    class Headers
      # Headers that we will never scrub, even if they land on the configuration blacklist.
      ALWAYS_WHITELISTED = %w[User-Agent].freeze

      # Headers that will always be scrubbed, even if whitelisted.
      ALWAYS_BLACKLISTED = %w[Cookie Authorization].freeze

      private_constant :ALWAYS_WHITELISTED, :ALWAYS_BLACKLISTED

      # @param headers [Hash]
      def initialize(headers)
        @headers = headers
        @no_whitelist = Castle.config.whitelisted.empty?
      end

      # Serialize HTTP headers
      # @return [Hash]
      def call
        @headers.each_with_object({}) do |(name, value), acc|
          acc[name] = header_value(name, value)
        end
      end

      private

      # scrub header value
      # @param header [String]
      # @param value [String]
      # @return [TrueClass | FalseClass | String]
      def header_value(name, value)
         return true if ALWAYS_BLACKLISTED.include?(name)
         return value if ALWAYS_WHITELISTED.include?(name)
         return true if Castle.config.blacklisted.include?(name)
         return value if @no_whitelist || Castle.config.whitelisted.include?(name)

         true
      end
    end
  end
end

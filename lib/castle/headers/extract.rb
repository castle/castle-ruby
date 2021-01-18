# frozen_string_literal: true

module Castle
  module Headers
    # used for extraction of cookies and headers from the request
    class Extract
      # Headers that we will never scrub, even if they land on the configuration denylist.
      ALWAYS_ALLOWLISTED = %w[User-Agent].freeze

      # Headers that will always be scrubbed, even if allowlisted.
      ALWAYS_DENYLISTED = %w[Cookie Authorization].freeze

      private_constant :ALWAYS_ALLOWLISTED, :ALWAYS_DENYLISTED

      # @param headers [Hash]
      # @param config [Castle::Configuration, Castle::SingletonConfiguration]
      def initialize(headers, config = Castle.config)
        @headers = headers
        @config = config
        @no_allowlist = config.allowlisted.empty?
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
      # @param name [String]
      # @param value [String]
      # @return [TrueClass | FalseClass | String]
      def header_value(name, value)
        return true if ALWAYS_DENYLISTED.include?(name)
        return value if ALWAYS_ALLOWLISTED.include?(name)
        return true if @config.denylisted.include?(name)
        return value if @no_allowlist || @config.allowlisted.include?(name)

        true
      end
    end
  end
end

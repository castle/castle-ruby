# frozen_string_literal: true

module Castle
  module Extractors
    # used for extraction of ip from the request
    class IP
      # ordered list of ip headers for ip extraction
      DEFAULT = %w[X-Forwarded-For Remote-Addr].freeze

      private_constant :DEFAULT

      # @param headers [Hash]
      def initialize(headers)
        @headers = headers
        @ip_headers = Castle.config.ip_headers.empty? ? DEFAULT : Castle.config.ip_headers
        @proxies = Castle.config.trusted_proxies + Castle::Configuration::TRUSTED_PROXIES
      end

      # Order of headers:
      #   .... list of headers defined by ip_headers
      #   X-Forwarded-For
      #   Remote-Addr
      # @return [String]
      def call
        all_ips = []

        @ip_headers.each do |ip_header|
          ips = ips_from(ip_header)
          ip_value = remove_proxies(ips).last
          return ip_value if ip_value

          all_ips.push(*ips)
        end

        # fallback to first whatever ip
        all_ips.first
      end

      private

      # @param ips [Array<String>]
      # @return [Array<String>]
      def remove_proxies(ips)
        ips.reject { |ip| proxy?(ip) }
      end

      # @param ip [String]
      # @return [Boolean]
      def proxy?(ip)
        @proxies.any? { |proxy| proxy.match(ip) }
      end

      # @param header [String]
      # @return [Array<String>]
      def ips_from(header)
        value = @headers[header]

        return [] unless value

        value.strip.split(/[,\s]+/)
      end
    end
  end
end

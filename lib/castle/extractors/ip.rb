# frozen_string_literal: true

module Castle
  module Extractors
    # used for extraction of ip from the request
    class IP
      # ordered list of ip headers for ip extraction
      DEFAULT = %w[X-Forwarded-For Client-Ip Remote-Addr].freeze
      # default header fallback when ip is not found
      FALLBACK = 'Remote-Addr'

      private_constant :FALLBACK, :DEFAULT

      # @param headers [Hash]
      def initialize(headers)
        @headers = headers
        @ip_headers = Castle.config.ip_headers + DEFAULT
        @proxies = Castle.config.trusted_proxies + Castle::Configuration::TRUSTED_PROXIES
      end

      # Order of headers:
      #   .... list of headers defined by ip_headers
      #   X-Forwarded-For
      #   Client-Ip is
      #   Remote-Addr
      # @return [String]
      def call
        @ip_headers.each do |ip_header|
          ip_value = calculate_ip(ip_header)
          return ip_value if ip_value
        end

        @headers[FALLBACK]
      end

      private

      # @param header [String]
      # @return [String]
      def calculate_ip(header)
        ips = ips_from(header)
        remove_proxies(ips).first
      end

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

        value.strip.split(/[,\s]+/).reverse
      end
    end
  end
end

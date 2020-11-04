# frozen_string_literal: true

module Castle
  module IP
    # used for extraction of ip from the request
    class Extract
      # ordered list of ip headers for ip extraction
      DEFAULT = %w[X-Forwarded-For Remote-Addr].freeze
      # list of header which are used with proxy depth setting
      DEPTH_RELATED = %w[X-Forwarded-For].freeze

      private_constant :DEFAULT

      # @param headers [Hash]
      def initialize(headers)
        @headers = headers
        @ip_headers = Castle.config.ip_headers.empty? ? DEFAULT : Castle.config.ip_headers
        @proxies = Castle.config.trusted_proxies + Castle::Configuration::TRUSTED_PROXIES
        @trust_proxy_chain = Castle.config.trust_proxy_chain
        @trusted_proxy_depth = Castle.config.trusted_proxy_depth
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
          ip_value = remove_proxies(ips)

          return ip_value if ip_value

          all_ips.push(*ips)
        end

        # fallback to first listed ip
        all_ips.first
      end

      private

      # @param ips [Array<String>]
      # @return [Array<String>]
      def remove_proxies(ips)
        return ips.first if @trust_proxy_chain

        ips.reject { |ip| proxy?(ip) }.last
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

        ips = value.strip.split(/[,\s]+/)

        limit_proxy_depth(ips, header)
      end

      # @param ips [Array<String>]
      # @param ip_header [String]
      # @return [Array<String>]
      def limit_proxy_depth(ips, ip_header)
        ips.pop(@trusted_proxy_depth) if DEPTH_RELATED.include?(ip_header)

        ips
      end
    end
  end
end

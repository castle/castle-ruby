# frozen_string_literal: true

require 'uri'

module Castle
  # manages configuration variables
  class Configuration
    # API endpoint
    BASE_URL = 'https://api.castle.io/v1'
    REQUEST_TIMEOUT = 1000 # in milliseconds

    # regexp of trusted proxies which is always appended to the trusted proxy list
    TRUSTED_PROXIES = [
      /
      \A127\.0\.0\.1\Z|
      \A(10|172\.(1[6-9]|2[0-9]|30|31)|192\.168)\.|
      \A::1\Z|\Afd[0-9a-f]{2}:.+|
      \Alocalhost\Z|
      \Aunix\Z|
      \Aunix:
    /ix
    ].freeze

    # @note this value is not assigned as we don't recommend using a allowlist. If you need to use
    #   one, this constant is provided as a good default.
    DEFAULT_ALLOWLIST = %w[
      Accept
      Accept-Charset
      Accept-Datetime
      Accept-Encoding
      Accept-Language
      Cache-Control
      Connection
      Content-Length
      Content-Type
      Dnt
      Host
      Origin
      Pragma
      Referer
      Sec-Fetch-Dest
      Sec-Fetch-Mode
      Sec-Fetch-Site
      Sec-Fetch-User
      Te
      Upgrade-Insecure-Requests
      User-Agent
      X-Castle-Client-Id
      X-Requested-With
    ].freeze

    attr_accessor :request_timeout, :trust_proxy_chain, :logger
    attr_reader :api_secret,
                :allowlisted,
                :denylisted,
                :failover_strategy,
                :ip_headers,
                :trusted_proxies,
                :trusted_proxy_depth,
                :base_url

    def initialize
      @header_format = Castle::Headers::Format
      @request_timeout = REQUEST_TIMEOUT
      reset
    end

    def reset
      self.failover_strategy = Castle::Failover::Strategy::ALLOW
      self.base_url = BASE_URL
      self.allowlisted = [].freeze
      self.denylisted = [].freeze
      self.api_secret = ENV.fetch('CASTLE_API_SECRET', '')
      self.ip_headers = [].freeze
      self.trusted_proxies = [].freeze
      self.trust_proxy_chain = false
      self.trusted_proxy_depth = nil
      self.logger = nil
    end

    def base_url=(value)
      @base_url = URI(value)
    end

    def api_secret=(value)
      @api_secret = value.to_s
    end

    def allowlisted=(value)
      @allowlisted =
        (value ? value.map { |header| @header_format.call(header) } : []).freeze
    end

    def denylisted=(value)
      @denylisted =
        (value ? value.map { |header| @header_format.call(header) } : []).freeze
    end

    # sets ip headers
    # @param value [Array<String>]
    def ip_headers=(value)
      unless value.is_a?(Array)
        raise Castle::ConfigurationError, 'ip headers must be an Array'
      end

      @ip_headers = value.map { |header| @header_format.call(header) }.freeze
    end

    # sets trusted proxies
    # @param value [Array<String,Regexp>]
    def trusted_proxies=(value)
      unless value.is_a?(Array)
        raise Castle::ConfigurationError, 'trusted proxies must be an Array'
      end

      @trusted_proxies = value
    end

    # @param value [String,Number,NilClass]
    def trusted_proxy_depth=(value)
      @trusted_proxy_depth = value.to_i
    end

    def valid?
      !api_secret.to_s.empty? && !base_url.host.to_s.empty? &&
        !base_url.port.to_s.empty?
    end

    def failover_strategy=(value)
      @failover_strategy =
        Castle::Failover::STRATEGIES.detect do |strategy|
          strategy == value.to_sym
        end
      if @failover_strategy.nil?
        raise Castle::ConfigurationError, 'unrecognized failover strategy'
      end
    end

    private

    def respond_to_missing?(method_name, _include_private)
      /^(\w+)=$/ =~ method_name
    end

    def method_missing(setting, *_args)
      raise Castle::ConfigurationError, "there is no such a config #{setting}"
    end
  end
end

# frozen_string_literal: true

require 'singleton'
require 'uri'

module Castle
  # manages configuration variables
  class Configuration
    include Singleton

    URL = 'https://api.castle.io/v1'
    FAILOVER_STRATEGY = :allow
    REQUEST_TIMEOUT = 500 # in milliseconds
    FAILOVER_STRATEGIES = %i[allow deny challenge throw].freeze
    # regexp of trusted proxies which is always appended to the trusted proxy list
    TRUSTED_PROXIES = [/
      \A127\.0\.0\.1\Z|
      \A(10|172\.(1[6-9]|2[0-9]|30|31)|192\.168)\.|
      \A::1\Z|\Afd[0-9a-f]{2}:.+|
      \Alocalhost\Z|
      \Aunix\Z|
      \Aunix:
    /ix].freeze

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
      Host
      Origin
      Pragma
      Referer
      TE
      Upgrade-Insecure-Requests
      X-Castle-Client-Id
    ].freeze

    attr_accessor  :request_timeout, :url, :trust_proxy_chain
    attr_reader :api_secret, :allowlisted, :denylisted, :failover_strategy, :ip_headers,
      :trusted_proxies, :trusted_proxy_depth

    def initialize
      @formatter = Castle::HeadersFormatter
      @request_timeout = REQUEST_TIMEOUT
      reset
    end

    def reset
      self.failover_strategy = FAILOVER_STRATEGY
      self.url = URL
      self.allowlisted = [].freeze
      self.denylisted = [].freeze
      self.api_secret = ENV.fetch('CASTLE_API_SECRET', '')
      self.ip_headers = [].freeze
      self.trusted_proxies = [].freeze
      self.trust_proxy_chain = false
      self.trusted_proxy_depth = nil
    end

    def url=(value)
      @url = URI(value)
    end

    def api_secret=(value)
      @api_secret = value.to_s
    end

    def allowlisted=(value)
      @allowlisted = (value ? value.map { |header| @formatter.call(header) } : []).freeze
    end

    def denylisted=(value)
      @denylisted = (value ? value.map { |header| @formatter.call(header) } : []).freeze
    end

    # sets ip headers
    # @param value [Array<String>]
    def ip_headers=(value)
      raise Castle::ConfigurationError, 'ip headers must be an Array' unless value.is_a?(Array)

      @ip_headers = value.map { |header| @formatter.call(header) }.freeze
    end

    # sets trusted proxies
    # @param value [Array<String,Regexp>]
    def trusted_proxies=(value)
      raise Castle::ConfigurationError, 'trusted proxies must be an Array' unless value.is_a?(Array)

      @trusted_proxies = value
    end

    # @param value [String,Number,NilClass]
    def trusted_proxy_depth=(value)
      @trusted_proxy_depth = value.to_i
    end

    def valid?
      !api_secret.to_s.empty? && !url.host.to_s.empty? && !url.port.to_s.empty?
    end

    def failover_strategy=(value)
      @failover_strategy = FAILOVER_STRATEGIES.detect { |strategy| strategy == value.to_sym }
      raise Castle::ConfigurationError, 'unrecognized failover strategy' if @failover_strategy.nil?
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

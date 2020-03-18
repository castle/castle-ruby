# frozen_string_literal: true

module Castle
  # manages configuration variables
  class Configuration
    HOST = 'api.castle.io'
    PORT = 443
    URL_PREFIX = 'v1'
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

    # @note this value is not assigned as we don't recommend using a whitelist. If you need to use
    #   one, this constant is provided as a good default.
    DEFAULT_WHITELIST = %w[
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

    attr_accessor :host, :port, :request_timeout, :url_prefix
    attr_reader :api_secret, :whitelisted, :blacklisted, :failover_strategy, :ip_headers, :trusted_proxies

    def initialize
      @formatter = Castle::HeaderFormatter.new
      @request_timeout = REQUEST_TIMEOUT
      self.failover_strategy = FAILOVER_STRATEGY
      self.host = HOST
      self.port = PORT
      self.url_prefix = URL_PREFIX
      self.whitelisted = [].freeze
      self.blacklisted = [].freeze
      self.api_secret = ENV.fetch('CASTLE_API_SECRET', '')
      self.ip_headers = [].freeze
      self.trusted_proxies = [].freeze
    end

    def api_secret=(value)
      @api_secret = value.to_s
    end

    def whitelisted=(value)
      @whitelisted = (value ? value.map { |header| @formatter.call(header) } : []).freeze
    end

    def blacklisted=(value)
      @blacklisted = (value ? value.map { |header| @formatter.call(header) } : []).freeze
    end

    # sets ip headers
    # @param value [Array<String>]
    def ip_headers=(value)
      raise Castle::ConfigurationError, 'ip headers must be an Array' unless value.is_a?(Array)

      @ip_headers = value.map { |header| @formatter.call(header) }.freeze
    end

    # sets trusted proxies
    # @param value [Array<String|Regexp>]
    def trusted_proxies=(value)
      raise Castle::ConfigurationError, 'trusted proxies must be an Array' unless value.is_a?(Array)

      @trusted_proxies = value
    end

    def valid?
      !api_secret.to_s.empty? && !host.to_s.empty? && !port.to_s.empty?
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

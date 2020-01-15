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
    attr_reader :api_secret, :whitelisted, :blacklisted, :failover_strategy

    def initialize
      @formatter = Castle::HeaderFormatter.new
      @request_timeout = REQUEST_TIMEOUT
      self.failover_strategy = FAILOVER_STRATEGY
      self.host = HOST
      self.port = PORT
      self.url_prefix = URL_PREFIX
      self.whitelisted = []
      self.blacklisted = []
      self.api_secret = ''
    end

    def api_secret=(value)
      @api_secret = ENV.fetch('CASTLE_API_SECRET', value).to_s
    end

    def whitelisted=(value)
      @whitelisted = (value ? value.map { |header| @formatter.call(header) } : []).freeze
    end

    def blacklisted=(value)
      @blacklisted = (value ? value.map { |header| @formatter.call(header) } : []).freeze
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

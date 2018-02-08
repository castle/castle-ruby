# frozen_string_literal: true

module Castle
  # manages configuration variables
  class Configuration
    REQUEST_TIMEOUT = 500 # in milliseconds
    FAILOVER_STRATEGIES = %i[allow deny challenge throw].freeze
    WHITELISTED = [
      'User-Agent',
      'Accept-Language',
      'Accept-Encoding',
      'Accept-Charset',
      'Accept',
      'Accept-Datetime',
      'X-Forwarded-For',
      'Forwarded',
      'X-Forwarded',
      'X-Real-IP',
      'REMOTE_ADDR',
      'X-Forwarded-For',
      'CF_CONNECTING_IP'
    ].freeze

    BLACKLISTED = ['HTTP_COOKIE'].freeze

    attr_accessor :host, :port, :request_timeout, :url_prefix
    attr_reader :api_secret, :whitelisted, :blacklisted, :failover_strategy

    def initialize
      @formatter = Castle::HeaderFormatter.new
      @request_timeout = REQUEST_TIMEOUT
      self.failover_strategy = :allow
      self.host = 'api.castle.io'
      self.port = 443
      self.url_prefix = 'v1'
      self.whitelisted = WHITELISTED
      self.blacklisted = BLACKLISTED
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

    def method_missing(m, *_args)
      raise Castle::ConfigurationError, "there is no such a config #{m}"
    end
  end
end

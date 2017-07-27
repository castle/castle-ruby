# frozen_string_literal: true

module Castle
  # manages configuration variables
  class Configuration
    SUPPORTED = %i[request_timeout api_secret api_endpoint].freeze
    REQUEST_TIMEOUT = 500 # in milliseconds
    API_ENDPOINT = 'https://api.castle.io/v1'
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
      'REMOTE_ADDR'
    ].freeze

    BLACKLISTED = ['HTTP_COOKIE'].freeze

    attr_accessor :request_timeout
    attr_reader :api_secret, :api_endpoint, :whitelisted, :blacklisted, :failover_strategy

    def initialize
      @formatter = Castle::HeaderFormatter.new
      @request_timeout = REQUEST_TIMEOUT
      self.failover_strategy = :allow
      self.api_endpoint = API_ENDPOINT
      self.whitelisted = WHITELISTED
      self.blacklisted = BLACKLISTED
      self.api_secret = ''
    end

    def api_endpoint=(value)
      @api_endpoint = URI(
        ENV.fetch('CASTLE_API_ENDPOINT', value)
      )
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
      !api_secret.to_s.empty? && !api_endpoint.scheme.nil?
    end

    def failover_strategy=(value)
      @failover_strategy = FAILOVER_STRATEGIES.detect { |strategy| strategy == value.to_sym }
      raise Castle::ConfigurationError, 'there is no such a strategy' if @failover_strategy.nil?
      @failover_strategy
    end

    private

    def respond_to_missing?(method_name, _include_private)
      /^(\w+)=$/ =~ method_name
    end

    def method_missing(_m, *_args)
      raise Castle::ConfigurationError, 'there is no such a config'
    end
  end
end

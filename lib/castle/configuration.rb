# frozen_string_literal: true

module Castle
  # manages configuration variables
  class Configuration
    REQUEST_TIMEOUT = 0.5 # in seconds
    API_ENDPOINT = 'https://api.castle.io/v1'
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

    attr_accessor :request_timeout, :source_header
    attr_reader :api_secret, :api_endpoint, :whitelisted, :blacklisted

    def initialize
      @formatter = Castle::HeaderFormatter.new
      @request_timeout = REQUEST_TIMEOUT
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
      @whitelisted = value ? value.map { |header| @formatter.call(header) } : []
    end

    def blacklisted=(value)
      @blacklisted = value ? value.map { |header| @formatter.call(header) } : []
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

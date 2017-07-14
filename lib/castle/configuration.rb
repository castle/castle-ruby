# frozen_string_literal: true

module Castle
  # manages configuration variables
  class Configuration
    SUPPORTED = %i[source_header request_timeout api_secret api_endpoint].freeze
    REQUEST_TIMEOUT = 30.0
    API_ENDPOINT = 'https://api.castle.io/v1'

    attr_accessor :request_timeout, :source_header
    attr_reader :api_secret, :api_endpoint

    def initialize
      @request_timeout = REQUEST_TIMEOUT
      self.api_endpoint = API_ENDPOINT
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

    private

    def respond_to_missing?(method_name, _include_private)
      /^(\w+)=$/ =~ method_name
    end

    def method_missing(_m, *_args)
      raise Castle::ConfigurationError, 'there is no such a config'
    end
  end
end

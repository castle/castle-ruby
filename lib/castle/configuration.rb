# frozen_string_literal: true

module Castle
  # manages configuration variables
  class Configuration
    attr_accessor :request_timeout, :source_header
    attr_reader :api_endpoint
    attr_writer :api_secret

    def initialize
      @request_timeout = 30.0
      self.api_endpoint =
        ENV['CASTLE_API_ENDPOINT'] || 'https://api.castle.io/v1'
    end

    def api_secret
      ENV['CASTLE_API_SECRET'] || @api_secret || ''
    end

    def api_endpoint=(value)
      @api_endpoint = URI(value)
    end
  end
end

module Castle
  class << self
    def configure(config_hash=nil)
      if config_hash
        config_hash.each do |k,v|
          config.send("#{k}=", v)
        end
      end

      yield(config) if block_given?
    end

    def config
      @configuration ||= Castle::Configuration.new
    end

    def api_secret=(api_secret)
      config.api_secret = api_secret
    end
  end

  class Configuration
    attr_accessor :request_timeout
    attr_accessor :source_header

    def initialize
      self.request_timeout = 30.0
      self.api_endpoint =
        ENV['CASTLE_API_ENDPOINT'] || 'https://api.castle.io/v1'
    end

    def api_secret
      ENV['CASTLE_API_SECRET'] || @_api_secret || ''
    end

    def api_secret=(value)
      @_api_secret = value
    end

    def api_endpoint
      @_api_endpoint
    end

    def api_endpoint=(value)
      @_api_endpoint = URI(value)
    end
  end
end

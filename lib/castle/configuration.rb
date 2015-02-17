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

    def initialize
      self.request_timeout = 30.0
    end

    def api_secret
      ENV['CASTLE_API_SECRET'] || @_api_secret || ''
    end

    def api_secret=(value)
      @_api_secret = value
    end
  end
end

module Userbin
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
      @configuration ||= Userbin::Configuration.new
    end
  end

  class Configuration
    attr_accessor :current_user
    attr_accessor :create_user
    attr_accessor :exclude_regexp
    attr_accessor :find_user
    attr_accessor :protected_path
    attr_accessor :root_path
    attr_accessor :skip_script_injection

    def initialize
      self.skip_script_injection = false
    end

    def app_id
      ENV['USERBIN_APP_ID'] || @_app_id
    end

    def app_id=(value)
      @_app_id = value
    end

    def api_secret
      ENV['USERBIN_API_SECRET'] || @_api_secret
    end

    def api_secret=(value)
      @_api_secret = value
    end
  end
end

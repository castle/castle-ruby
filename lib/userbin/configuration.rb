module Userbin
  class Configuration
    attr_accessor :create_user
    attr_accessor :find_user
    attr_accessor :protected_path
    attr_accessor :root_path
    attr_accessor :skip_script_injection

    # restricted_path is obsolete
    alias :restricted_path :protected_path
    alias :restricted_path= :protected_path=

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

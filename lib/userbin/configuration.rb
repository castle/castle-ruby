module Userbin
  class Configuration
    attr_accessor :app_id
    attr_accessor :api_secret
    attr_accessor :skip_script_injection
    attr_accessor :create_user
    attr_accessor :find_user
    attr_accessor :protected_path
    attr_accessor :root_path

    # restricted_path is obsolete
    alias :restricted_path :protected_path
    alias :restricted_path= :protected_path=

    def initialize
      self.app_id = ENV["USERBIN_APP_ID"]
      self.api_secret = ENV["USERBIN_API_SECRET"]

      self.skip_script_injection = false
    end
  end
end

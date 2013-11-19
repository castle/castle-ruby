module Userbin
  class Configuration
    attr_accessor :app_id
    attr_accessor :api_secret
    attr_accessor :auto_include_tags
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

      self.auto_include_tags = true
    end
  end
end

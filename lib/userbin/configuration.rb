module Userbin
  class Configuration
    attr_accessor :app_id
    attr_accessor :api_secret
    attr_accessor :current_user
    attr_accessor :auto_include_tags
    attr_accessor :restricted_path

    def initialize
      self.app_id = ENV["USERBIN_APP_ID"]
      self.api_secret = ENV["USERBIN_API_SECRET"]

      self.auto_include_tags = true
    end
  end
end

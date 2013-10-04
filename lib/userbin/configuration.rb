module Userbin
  class Configuration
    attr_accessor :app_id
    attr_accessor :api_secret
    attr_accessor :user_model
    attr_accessor :restricted_path

    def initialize
      self.app_id = ENV["USERBIN_APP_ID"]
      self.api_secret = ENV["USERBIN_API_SECRET"]
    end
  end
end

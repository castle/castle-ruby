module Userbin
  class Configuration
    attr_accessor :app_id
    attr_accessor :api_secret
    attr_accessor :current_user
    attr_accessor :restricted_path
    attr_accessor :root_path

    def initialize
      self.app_id = ENV["USERBIN_APP_ID"]
      self.api_secret = ENV["USERBIN_API_SECRET"]

      self.root_path = '/'
    end
  end
end

require 'her'
require 'faraday_middleware'
require 'multi_json'
require 'openssl'
require 'net/http'
require 'request_store'

require "userbin/configuration"
require "userbin/faraday"
require "userbin/jwt"
require "userbin/utils"
require "userbin/helpers"
require "userbin/errors"

module Userbin
  API = Userbin.setup_api
end

# These need to be required after setting up Her
require "userbin/models/base"
require "userbin/models/challenge"
require "userbin/models/session"
require "userbin/models/user"

module Userbin
  def self.user_agent
    @uname ||= get_uname
    lang_version = "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})"

    {
      :bindings_version => Userbin::VERSION,
      :lang => 'ruby',
      :lang_version => lang_version,
      :platform => RUBY_PLATFORM,
      :publisher => 'userbin',
      :uname => @uname
    }
  end

  def self.get_uname
    `uname -a 2>/dev/null`.strip if RUBY_PLATFORM =~ /linux|darwin/i
  rescue Errno::ENOMEM => ex # couldn't create subprocess
    "uname lookup failed"
  end

  def self.request_headers(api_key)
    headers = {
      :user_agent => "Userbin/v1 RubyBindings/#{Userbin::VERSION}",
    }

    begin
      headers.update(:x_userbin_client_user_agent => JSON.generate(user_agent))
    rescue => e
      headers.update(:x_userbin_client_raw_user_agent => user_agent.inspect,
                     :error => "#{e} (#{e.class})")
    end
  end
end

require 'her'
require 'faraday_middleware'
require 'multi_json'
require 'openssl'
require 'net/http'
require 'request_store'

require "userbin/version"
require "userbin/configuration"
require "userbin/request"
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

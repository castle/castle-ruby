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

module Userbin
  API = Userbin.setup_api
end

# These need to be required after setting up Her
require "userbin/models/base"
require "userbin/models/challenge"
require "userbin/models/session"
require "userbin/models/user"

class Userbin::Error < Exception; end
class Userbin::Forbidden < Userbin::Error; end
class Userbin::UserUnauthorizedError < Userbin::Error; end
class Userbin::SecurityError < Userbin::Error; end
class Userbin::ConfigurationError < Userbin::Error; end

class Userbin::ChallengeException < Userbin::Error
  attr_reader :challenge
  def initialize(challenge)
    @challenge = challenge
  end
end

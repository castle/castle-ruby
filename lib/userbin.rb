require 'her'
require 'multi_json'
require 'openssl'
require 'net/http'

require "userbin/userbin"
require "userbin/faraday"

api_endpoint = ENV.fetch('USERBIN_API_ENDPOINT') {
  "https://api.userbin.com/v1"
}

@api = Her::API.setup url: api_endpoint do |c|
  c.use Userbin::BasicAuth
  c.use Faraday::Request::UrlEncoded
  c.use Userbin::JSONParser
  c.use Faraday::Adapter::NetHttp
end

require "userbin/configuration"
require "userbin/jwt"

require "userbin/models/base"
require "userbin/models/user"
require "userbin/models/session"
require "userbin/models/token"
require "userbin/models/login_token"
require "userbin/models/signup_token"
require "userbin/models/challenge"

class Userbin::Error < Exception; end
class Userbin::SecurityError < Userbin::Error; end
class Userbin::ConfigurationError < Userbin::Error; end

class Userbin::LockedException < Userbin::Error; end
class Userbin::NotFoundError < Userbin::Error; end
class Userbin::ServerError < Userbin::Error; end
class Userbin::Unauthorized < Userbin::Error; end
class Userbin::UnconfirmedException < Userbin::Error; end

class Userbin::ChallengeException < Userbin::Error
  attr_reader :challenge
  def initialize(challenge)
    @challenge = challenge
  end
end

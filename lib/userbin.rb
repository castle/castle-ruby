require 'her'
require 'faraday_middleware'
require 'multi_json'
require 'openssl'
require 'net/http'

require "userbin/configuration"
require "userbin/faraday"
require "userbin/jwt"

api_endpoint = ENV.fetch('USERBIN_API_ENDPOINT') {
  "https://api.userbin.com/v1"
}

@api = Her::API.setup url: api_endpoint do |c|
  c.use Userbin::BasicAuth
  c.use FaradayMiddleware::EncodeJson
  c.use Userbin::JSONParser
  c.use Faraday::Adapter::NetHttp
end

# These need to be required after setting up Her
require "userbin/models/base"
require "userbin/models/challenge"
require "userbin/models/session"
require "userbin/models/user"

class Userbin::Error < Exception; end
class Userbin::SecurityError < Userbin::Error; end
class Userbin::ConfigurationError < Userbin::Error; end

class Userbin::ChallengeException < Userbin::Error
  attr_reader :challenge
  def initialize(challenge)
    @challenge = challenge
  end
end

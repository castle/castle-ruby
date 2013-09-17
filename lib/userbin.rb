require 'her'
require 'multi_json'
require 'openssl'
require 'net/http'

require "userbin/userbin"
require "userbin/basic_auth"

api_endpoint = ENV.fetch('USERBIN_API_ENDPOINT') {
  "https://userbin.com/api/v0"
}

@api = Her::API.setup url: api_endpoint do |c|
  c.use Userbin::BasicAuth
  c.use Faraday::Request::UrlEncoded
  c.use Userbin::ParseSignedJSON
  c.use Faraday::Adapter::NetHttp
  c.use Userbin::VerifySignature
end

require "userbin/current"
require "userbin/session"
require "userbin/authentication"

class Userbin::Error < Exception; end
class Userbin::SecurityError < Userbin::Error; end



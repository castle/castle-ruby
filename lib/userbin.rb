require 'her'
require 'userbin/ext/her'
require 'faraday_middleware'
require 'multi_json'
require 'openssl'
require 'net/http'
require 'request_store'
require 'active_support/core_ext/hash/indifferent_access'

require 'userbin/version'

require 'userbin/configuration'
require 'userbin/client'
require 'userbin/errors'
require 'userbin/token_store'
require 'userbin/jwt'
require 'userbin/utils'
require 'userbin/request'
require 'userbin/session_token'

require 'userbin/support/cookie_store'
require 'userbin/support/rails' if defined?(Rails::Railtie)
if defined?(Sinatra::Base)
  if defined?(Padrino)
    require 'userbin/support/padrino'
  else
    require 'userbin/support/sinatra'
  end
end

module Userbin
  API = Userbin.setup_api
end

# These need to be required after setting up Her
require 'userbin/models/model'
require 'userbin/models/account'
require 'userbin/models/event'
require 'userbin/models/challenge'
require 'userbin/models/context'
require 'userbin/models/monitoring'
require 'userbin/models/pairing'
require 'userbin/models/backup_codes'
require 'userbin/models/session'
require 'userbin/models/trusted_device'
require 'userbin/models/user'

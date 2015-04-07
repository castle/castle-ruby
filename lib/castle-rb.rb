require 'her'
require 'castle-rb/ext/her'
require 'faraday_middleware'
require 'multi_json'
require 'openssl'
require 'net/http'
require 'request_store'
require 'active_support/core_ext/hash/indifferent_access'

require 'castle-rb/version'

require 'castle-rb/configuration'
require 'castle-rb/client'
require 'castle-rb/errors'
require 'castle-rb/token_store'
require 'castle-rb/jwt'
require 'castle-rb/utils'
require 'castle-rb/request'
require 'castle-rb/session_token'

require 'castle-rb/support/cookie_store'
require 'castle-rb/support/rails' if defined?(Rails::Railtie)
if defined?(Sinatra::Base)
  if defined?(Padrino)
    require 'castle-rb/support/padrino'
  else
    require 'castle-rb/support/sinatra'
  end
end

module Castle
  API = Castle.setup_api

  def self.secure_encode(properties = {})
    ::JWT.encode(properties, Castle.config.api_secret)
  end
end

# These need to be required after setting up Her
require 'castle-rb/models/model'
require 'castle-rb/models/account'
require 'castle-rb/models/event'
require 'castle-rb/models/challenge'
require 'castle-rb/models/context'
require 'castle-rb/models/monitoring'
require 'castle-rb/models/pairing'
require 'castle-rb/models/backup_codes'
require 'castle-rb/models/recommendation'
require 'castle-rb/models/session'
require 'castle-rb/models/trusted_device'
require 'castle-rb/models/user'

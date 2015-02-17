require 'her'
require 'castle/ext/her'
require 'faraday_middleware'
require 'multi_json'
require 'openssl'
require 'net/http'
require 'request_store'
require 'active_support/core_ext/hash/indifferent_access'

require 'castle/version'

require 'castle/configuration'
require 'castle/client'
require 'castle/errors'
require 'castle/token_store'
require 'castle/jwt'
require 'castle/utils'
require 'castle/request'
require 'castle/session_token'

require 'castle/support/cookie_store'
require 'castle/support/rails' if defined?(Rails::Railtie)
if defined?(Sinatra::Base)
  if defined?(Padrino)
    require 'castle/support/padrino'
  else
    require 'castle/support/sinatra'
  end
end

module Castle
  API = Castle.setup_api
end

# These need to be required after setting up Her
require 'castle/models/model'
require 'castle/models/account'
require 'castle/models/event'
require 'castle/models/challenge'
require 'castle/models/context'
require 'castle/models/monitoring'
require 'castle/models/pairing'
require 'castle/models/backup_codes'
require 'castle/models/recommendation'
require 'castle/models/session'
require 'castle/models/trusted_device'
require 'castle/models/user'

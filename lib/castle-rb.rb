require 'castle-her'
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
require 'castle-rb/utils'
require 'castle-rb/request'

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
end

# These need to be required after setting up Her
require 'castle-rb/models/model'
require 'castle-rb/models/account'
require 'castle-rb/models/event'
require 'castle-rb/models/location'
require 'castle-rb/models/user_agent'
require 'castle-rb/models/context'
require 'castle-rb/models/user'
require 'castle-rb/models/label'
require 'castle-rb/models/authentication'

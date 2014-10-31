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
require 'userbin/session_store'
require 'userbin/trusted_token_store'
require 'userbin/jwt'
require 'userbin/utils'
require 'userbin/request'
require 'userbin/session_token'

module Userbin
  API = Userbin.setup_api
end

# These need to be required after setting up Her
require 'userbin/models/model'
require 'userbin/models/event'
require 'userbin/models/challenge'
require 'userbin/models/context'
require 'userbin/models/monitoring'
require 'userbin/models/pairing'
require 'userbin/models/backup_codes'
require 'userbin/models/session'
require 'userbin/models/trusted_device'
require 'userbin/models/user'

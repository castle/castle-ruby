# frozen_string_literal: true

require 'openssl'
require 'net/http'

require 'castle/version'

require 'castle/configuration'
require 'castle/client'
require 'castle/errors'
require 'castle/system'
require 'castle/headers'
require 'castle/response'
require 'castle/request'
require 'castle/api'
require 'castle/support/cookie_store'
require 'castle/support/rails' if defined?(Rails::Railtie)

if defined?(Sinatra::Base)
  if defined?(Padrino)
    require 'castle/support/padrino'
  else
    require 'castle/support/sinatra'
  end
end

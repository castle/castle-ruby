# frozen_string_literal: true

require 'openssl'
require 'net/http'

require 'castle-rb/version'

require 'castle-rb/configuration'
require 'castle-rb/client'
require 'castle-rb/errors'
require 'castle-rb/api'
require 'castle-rb/support/cookie_store'
require 'castle-rb/support/rails' if defined?(Rails::Railtie)

if defined?(Sinatra::Base)
  if defined?(Padrino)
    require 'castle-rb/support/padrino'
  else
    require 'castle-rb/support/sinatra'
  end
end

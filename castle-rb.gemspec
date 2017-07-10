# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'castle/version'

Gem::Specification.new do |s|
  s.name        = 'castle-rb'
  s.version     = Castle::VERSION
  s.summary     = 'Castle'
  s.description = 'The easiest way to protect your users'
  s.authors     = ['Johan Brissmyr']
  s.email       = 'johan@castle.io'
  s.homepage    = 'https://castle.io'
  s.license     = 'MIT'

  s.files       = Dir['{app,config,db,lib}/**/*'] + ['README.md']
  s.test_files  = Dir['spec/**/*']
  s.require_paths = ['lib']
end

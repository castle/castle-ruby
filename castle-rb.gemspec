# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'castle/version'

Gem::Specification.new do |s|
  s.name        = 'castle-rb'
  s.version     = Castle::VERSION
  s.summary     = 'Castle'
  s.description = 'Castle protects your users from account compromise'
  s.authors     = ['Johan Brissmyr']
  s.email       = 'johan@castle.io'
  s.homepage    = 'https://castle.io'
  s.license     = 'MIT'

  s.files       = Dir['{lib}/**/*'] + ['README.md']
  s.test_files  = Dir['spec/**/*']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.4'

  s.add_development_dependency 'appraisal'
end

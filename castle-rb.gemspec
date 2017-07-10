$:.push File.expand_path("../lib", __FILE__)

require 'castle-rb/version'

Gem::Specification.new do |s|
  s.name        = 'castle-rb'
  s.version     = Castle::VERSION
  s.summary     = "Castle"
  s.description = "The easiest way to protect your users"
  s.authors     = ["Johan Brissmyr"]
  s.email       = 'johan@castle.io'
  s.homepage    = 'https://castle.io'
  s.license     = 'MIT'

  s.files       = Dir["{app,config,db,lib}/**/*"] + ["README.md"]
  s.test_files  = Dir["spec/**/*"]
  s.require_paths = ['lib']

  s.add_development_dependency "pry", '~> 0.10.4'
  s.add_development_dependency "rack", "~> 1.6"
  s.add_development_dependency "rspec", '~> 3.5'
  s.add_development_dependency "webmock", "~> 1.21"
  s.add_development_dependency "polishgeeks-dev-tools", "~> 1.4.0"
end

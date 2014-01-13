$:.push File.expand_path("../lib", __FILE__)

require 'userbin/version'

Gem::Specification.new do |s|
  s.name        = 'userbin'
  s.version     = Userbin::VERSION
  s.date        = '2013-09-17'
  s.summary     = "Userbin"
  s.description = "Drop-in user login for mobile and web apps. Add a full user authentication stack to your application in minutes. Userbin is easily customized to fit your current design and infrastructure."
  s.authors     = ["Johan"]
  s.email       = 'johan@userbin.com'
  s.homepage    = 'https://userbin.com'
  s.license     = 'MIT'

  s.files       = Dir["{app,config,db,lib}/**/*"] + ["README.md"]
  s.test_files  = Dir["spec/**/*"]

  s.add_dependency "her", "~> 0.6.8"
  s.add_dependency "multi_json", "~> 1.0"
  s.add_dependency "jwt", "~> 0.1.8"

  s.add_development_dependency "rspec"
  s.add_development_dependency "rack"
  s.add_development_dependency "webmock"
end

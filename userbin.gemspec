$:.push File.expand_path("../lib", __FILE__)

require 'userbin/version'

Gem::Specification.new do |s|
  s.name        = 'userbin'
  s.version     = Userbin::VERSION
  s.summary     = "Userbin"
  s.description = "Secure your application with multi-factor authentication, user activity monitoring, and real-time threat protection."
  s.authors     = ["Johan"]
  s.email       = 'johan@userbin.com'
  s.homepage    = 'https://userbin.com'
  s.license     = 'MIT'

  s.files       = Dir["{app,config,db,lib}/**/*"] + ["README.md"]
  s.test_files  = Dir["spec/**/*"]

  s.add_dependency "her", "~> 0.6.8"
  s.add_dependency "faraday_middleware", "~> 0.9.1"
  s.add_dependency "multi_json", "~> 1.0"
  s.add_dependency "jwt", "~> 0.1.13"
  s.add_dependency "request_store", "~> 1.0.5"
  s.add_dependency "activesupport", ">= 3"

  s.add_development_dependency "rspec"
  s.add_development_dependency "rack"
  s.add_development_dependency "webmock"
  s.add_development_dependency "vcr"
  s.add_development_dependency "timecop"
end

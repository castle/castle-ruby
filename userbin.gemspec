Gem::Specification.new do |s|
  s.name        = 'userbin'
  s.version     = '0.1.3'
  s.date        = '2013-09-17'
  s.summary     = "Userbin"
  s.description = "Plug n’ play user accounts. The simplest way to integrate a full authentication and user management stack into your web application."
  s.authors     = ["Johan"]
  s.email       = 'johan@userbin.com'
  s.homepage    = 'https://userbin.com'
  s.license     = 'MIT'

  s.files       = Dir["{app,config,db,lib}/**/*"] + ["README.md"]
  s.test_files  = Dir["spec/**/*"]

  s.add_dependency "her", "~> 0.6.8"
  s.add_dependency "multi_json", "~> 1.0"

  s.add_development_dependency "rspec"
  s.add_development_dependency "rack"
  s.add_development_dependency "webmock"
end

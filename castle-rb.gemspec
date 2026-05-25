# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'castle/version'

Gem::Specification.new do |s|
  s.name = 'castle-rb'
  s.version = Castle::VERSION
  s.summary = 'Official Ruby SDK for the Castle fraud-prevention API'
  s.description = <<~DESC.strip
    Thin Ruby wrapper around the Castle HTTP API (https://reference.castle.io).
    Exposes Risk, Filter, and Log decisioning, full Lists / List Items CRUD,
    Privacy (GDPR) endpoints, and webhook signature verification, with helpers
    for Rails and Sinatra.
  DESC
  s.authors = ['Johan Brissmyr']
  s.email = 'team@castle.io'
  s.homepage = 'https://castle.io'
  s.license = 'MIT'

  s.metadata = {
    'homepage_uri' => s.homepage,
    'source_code_uri' => 'https://github.com/castle/castle-ruby',
    'changelog_uri' => 'https://github.com/castle/castle-ruby/blob/master/CHANGELOG.md',
    'bug_tracker_uri' => 'https://github.com/castle/castle-ruby/issues',
    'rubygems_mfa_required' => 'true'
  }

  s.files = Dir['{lib}/**/*'] + ['README.md', 'LICENSE', 'CHANGELOG.md']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 3.2'

  # Default gems that move to bundled gems in Ruby 3.5+
  s.add_dependency 'base64', '~> 0.2'
end

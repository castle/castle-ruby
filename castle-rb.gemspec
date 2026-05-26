# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'castle/version'

Gem::Specification.new do |s|
  s.name = 'castle-rb'
  s.version = Castle::VERSION
  s.summary = 'Official Ruby SDK for the Castle fraud and account-abuse prevention platform'
  s.description = <<~DESC.strip
    Castle protects web and mobile applications from account takeovers,
    fake accounts, bots, and other forms of account abuse. This gem is
    the official server-side Ruby SDK: it sends user events, retrieves
    real-time risk decisions, manages trust and block lists, and
    verifies webhook signatures.
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

  s.files = Dir['{lib}/**/*'] + %w[README.md LICENSE CHANGELOG.md]
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 3.2'

  # Default gems that move to bundled gems in Ruby 3.5+
  s.add_dependency 'base64', '~> 0.2'
end

# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'rack'
gem 'rake'

group :development do
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec', require: false
  gem 'syntax_tree', require: false
end

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
end

group :test do
  gem 'rspec'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'webmock'
end

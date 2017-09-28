# Change Log

## 3.0.0 (unreleased)

**Enhancements:**

- [#35](github.com/castle/castle-ruby/pull/35) dropped unused cookie store class, more informative Castle:Client constructor params
- [#30](github.com/castle/castle-ruby/pull/30) change request timeout to 500ms
- [#31](github.com/castle/castle-ruby/pull/31) remove auto-integration with Rails, Padrino, Sinatra (see BREAKING CHANGES, README)

**BREAKING CHANGES:**

- add `require 'castle/support/rails'` to have Castle client instance available as `castle` in your Rails controllers
- add `require 'castle/support/padrino'` to have Castle client instance available as `castle` in your Padrino helpers
- add `require 'castle/support/sinatra'` to have Castle client instance available as `castle` in your Sinatra helpers
- request timeout uses milliseconds unit from now on
- renamed `track!` to `enable_tracking`
- renamed `do_no_track!` to `disable_tracking`
- renamed `don_no_track?` to `tracked?` with opposite behaviour
- `Castle::Client` now takes options as a second argument
- drop support for ruby 2.1
- replaced `config.api_endpoint` with `config.host` and `config.port`
- renamed `fetch_review` to `Castle::Review.retrieve`

**Features:**

- [#32](github.com/castle/castle-ruby/pull/32) added helper for generating signature
- [#27](github.com/castle/castle-ruby/pull/27) added whitelisted and blacklisted to configuration (with defaults)
- [#41](github.com/castle/castle-ruby/pull/41) added Hanami helpers
- [#42](github.com/castle/castle-ruby/pull/42) added possibility to set do_not_track flag in `Castle::Client` options
- [#48](github.com/castle/castle-ruby/pull/48) added failover strategies for `authenticate` method

## 2.3.2

**Bug fixes:**

- fix for outdated Gemfile.lock

## 2.3.0

**Features:**

- extract `client_id` from `HTTP_X_CASTLE_CLIENT_ID` header when not found in cookies

**Enhancements:**

- repository cleanup

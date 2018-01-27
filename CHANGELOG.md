# Change Log

## master

## 3.4.0 (2018-01-27)

- [#101](github.com/castle/castle-ruby/pull/103) added `impersonate` method with `user_id`, `impersonator` and `context` options

## 3.3.1 (2018-01-22)

**Enhancements:**

- [#100](github.com/castle/castle-ruby/pull/100) use request.remote_ip and CF connecting IP in favour of request.ip if present
- [#100](github.com/castle/castle-ruby/pull/100) added `X-Forwarded-For` and `CF_CONNECTING_IP` to whitelisted headers

## 3.3.0 (2018-01-12)

**BREAKING CHANGES:**

- [#97](github.com/castle/castle-ruby/pull/97) when data is sent in batches you may want to wrap data options with to_options method before you send it to the worker (see README) to include proper timestamp in the query

**Features:**

- [#97](github.com/castle/castle-ruby/pull/97) `Castle::Client` has additional option `timestamp`, `timestamp` and `sent_at` time values are automatically added to the requests, added `Castle::Client.to_options` method which adds properly formatted timestamp param to the options

## 3.2.0 (2017-12-15)

**BREAKING CHANGES:**

- [#91](github.com/castle/castle-ruby/pull/91) symbolize keys for failover strategy

## 3.1.0 (2017-12-11)

**Enhancements:**

- [#90](github.com/castle/castle-ruby/pull/90) added ability to extract context object and initialize client with that object

**BREAKING CHANGES:**

- `Castle::Client.new` does not not build context object anymore
- to use previous functionality use `Castle::Client.from_request`

**Features:**

- added `Castle::Client.to_context` method which allows to generate context object from the request

## 3.0.1 (2017-11-20)

**Bug fixes:**

- [#84](github.com/castle/castle-ruby/pull/84) allow to use symbols for headers data

## 3.0.0 (2017-10-18)

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
- `Castle::Client.new` now takes options as a second argument
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

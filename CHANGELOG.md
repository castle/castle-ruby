# Changelog

## master

## 7.0.0 (2021-03-24)

**BREAKING CHANGES:**

- [#237](https://github.com/castle/castle-ruby/pull/237)
  * remove `identify` and `review` commands - they are no longer supported
  * remove `Castle::Events` - please use [recognized events](https://docs.castle.io/api_reference/#list-of-recognized-events) instead
  * remove `locale`, `user_agent`, `ip`, `headers`, `client_id` fields from context - no action required

**Enhancements:**

- [#237](https://github.com/castle/castle-ruby/pull/237)
  * add new supported top-level fields to the commands (`fingerprint`, `status`, `headers`, `ip`)
  * update Readme to reflect the changes

## 6.0.1 (2021-01-19)

**Enhancements:**

- [#234](https://github.com/castle/castle-ruby/pull/234) rename the namespace from `IP` to `IPs`

## 6.0.0 (2021-01-19)

**BREAKING CHANGES:**

- [#228](https://github.com/castle/castle-ruby/pull/228) change the impersonation-related DSL
- [#213](https://github.com/castle/castle-ruby/pull/213) rename config.url to config.base_url
- [#214](https://github.com/castle/castle-ruby/pull/214) reorganize structure of the SDK, Castle::API::Session renamed to Castle::Session
- [#216](https://github.com/castle/castle-ruby/pull/216) add new context and payload builders, changed DSL

**Enhancements:**
- [#231](https://github.com/castle/castle-ruby/pull/231) allow to instantiate the configuration
- [#230](https://github.com/castle/castle-ruby/pull/230) add webhooks verification
- [#223](https://github.com/castle/castle-ruby/pull/223), [#224](https://github.com/castle/castle-ruby/pull/224), [#225](https://github.com/castle/castle-ruby/pull/225), [#226](https://github.com/castle/castle-ruby/pull/226), [#227](https://github.com/castle/castle-ruby/pull/227) allow to manage the devices
- [#221](https://github.com/castle/castle-ruby/pull/221), [#222](https://github.com/castle/castle-ruby/pull/222) add more tests
- [#220](https://github.com/castle/castle-ruby/pull/220) update the default timeout
- [#218](https://github.com/castle/castle-ruby/pull/218) add logger config option
- [#212](https://github.com/castle/castle-ruby/pull/212) drop origin from the default context

## 5.0.0 (2020-09-29)

**BREAKING CHANGES:**

- [#207](https://github.com/castle/castle-ruby/pull/207) allow to reuse the connection (https://github.com/castle/castle-ruby#connection-reuse)
- [#204](https://github.com/castle/castle-ruby/pull/204) drop the configuration `host`, `port`, `url_prefix` options in favor of `url`
- [#203](https://github.com/castle/castle-ruby/pull/203) rename the `whitelist/blacklist` configuration option to `allowlist/denylist`

**Enhancements:**

- [#208](https://github.com/castle/castle-ruby/pull/208) bump the dependencies
- [#205](https://github.com/castle/castle-ruby/pull/205) extend DEFAULT_ALLOWLIST

## 4.3.0 (2020-05-22)

- [#197](https://github.com/castle/castle-ruby/pull/197) add `trusted_proxy_depth` and `trust_proxy_chain` configuration options

## 4.2.1 (2020-04-07)

- [#189](https://github.com/castle/castle-ruby/pull/189) added missing require

## 4.2.0 (2020-03-31)

- [#187](https://github.com/castle/castle-ruby/pull/187) dropped X-Client-Id from calculation of ip, drop appending default ip headers to the ip_header list config when config is provided (in that case default headers have to explicitly provided)


## 4.1.0 (2020-03-27)

- [#184](https://github.com/castle/castle-ruby/pull/184) added Castle::API::Session which exposes Net:Http instance for reuse
- [#183](https://github.com/castle/castle-ruby/pull/183) change format of url_prefix config and renamed internal classes/variables

## 4.0.0 (2020-03-19)

**BREAKING CHANGES:**

- [#178](https://github.com/castle/castle-ruby/pull/178) calculation of ip requires setup of ip_headers and trusted_proxies if needed
- [#180](https://github.com/castle/castle-ruby/pull/180) api key config overwrites env provided key
- [#175](https://github.com/castle/castle-ruby/pull/175) drop special handling of cf ip header (it has to provided by ip_headers config)

**Enhancements:**

- [#171](https://github.com/castle/castle-ruby/pull/171) test against Rails 5 and Rails 6

## 3.6.2 (2020-04-24)

- [#192](https://github.com/castle/castle-ruby/pull/192) fixed problem with symbols in env

## 3.6.1 (2020-01-16)

**Bug fixes**:

- [#168](https://github.com/castle/castle-ruby/pull/168) do not apply whitelisting by default

## 3.6.0 (2020-01-07)

**BREAKING CHANGES:**

- [#165](https://github.com/castle/castle-ruby/pull/165) support ruby >= 2.4

**Enhancements:**

- [#163](https://github.com/castle/castle-ruby/pull/163) scrub headers instead of dropping them


## 3.5.2 (2019-01-09)

**Enhancements:**

- [#131](https://github.com/castle/castle-ruby/pull/131) remove requirement for `user_id`

## 3.5.1 (2018-10-27)

**Enhancements:**

- [#132](https://github.com/castle/castle-ruby/pull/132) refactor internal `Castle::API` and it's components

## 3.5.0 (2018-04-18)

**BREAKING CHANGES:**

- [#119](https://github.com/castle/castle-ruby/pull/119) usage of `traits` key is deprecated, use `user_traits` instead

**Enhancements:**

- [#122](https://github.com/castle/castle-ruby/pull/122) `X-Castle-Client-Id` takes precedence over `cid` from `cookies`
- [#121](https://github.com/castle/castle-ruby/pull/121) raise Castle::ImpersonationFailed when impersonation request failed

## 3.4.2 (2018-02-26)

**Features:**

- [#115](https://github.com/castle/castle-ruby/pull/114) added reset option to `impersonate`

## 3.4.1 (2018-02-21)

- [#113](https://github.com/castle/castle-ruby/pull/113) support ruby >= 2.2.6

**Enhancements:**

- [#108](https://github.com/castle/castle-ruby/pull/108) move context and command validation to their own scope and classes, code cleanup

## 3.4.0 (2018-01-27)

- [#101](https://github.com/castle/castle-ruby/pull/103) added `impersonate` method with `user_id`, `impersonator` and `context` options

## 3.3.1 (2018-01-22)

**Enhancements:**

- [#100](https://github.com/castle/castle-ruby/pull/100) use request.remote_ip and CF connecting IP in favour of request.ip if present
- [#100](https://github.com/castle/castle-ruby/pull/100) added `X-Forwarded-For` and `CF_CONNECTING_IP` to whitelisted headers

## 3.3.0 (2018-01-12)

**BREAKING CHANGES:**

- [#97](https://github.com/castle/castle-ruby/pull/97) when data is sent in batches you may want to wrap data options with to_options method before you send it to the worker (see README) to include proper timestamp in the query

**Features:**

- [#97](https://github.com/castle/castle-ruby/pull/97) `Castle::Client` has additional option `timestamp`, `timestamp` and `sent_at` time values are automatically added to the requests, added `Castle::Client.to_options` method which adds properly formatted timestamp param to the options

## 3.2.0 (2017-12-15)

**BREAKING CHANGES:**

- [#91](https://github.com/castle/castle-ruby/pull/91) symbolize keys for failover strategy

## 3.1.0 (2017-12-11)

**Enhancements:**

- [#90](https://github.com/castle/castle-ruby/pull/90) added ability to extract context object and initialize client with that object

**BREAKING CHANGES:**

- `Castle::Client.new` does not not build context object anymore
- to use previous functionality use `Castle::Client.from_request`

**Features:**

- added `Castle::Client.to_context` method which allows to generate context object from the request

## 3.0.1 (2017-11-20)

**Bug fixes:**

- [#84](https://github.com/castle/castle-ruby/pull/84) allow to use symbols for headers data

## 3.0.0 (2017-10-18)

**Enhancements:**

- [#35](https://github.com/castle/castle-ruby/pull/35) dropped unused cookie store class, more informative Castle:Client constructor params
- [#30](https://github.com/castle/castle-ruby/pull/30) change request timeout to 500ms
- [#31](https://github.com/castle/castle-ruby/pull/31) remove auto-integration with Rails, Padrino, Sinatra (see BREAKING CHANGES, README)

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

- [#32](https://github.com/castle/castle-ruby/pull/32) added helper for generating signature
- [#27](https://github.com/castle/castle-ruby/pull/27) added whitelisted and blacklisted to configuration (with defaults)
- [#41](https://github.com/castle/castle-ruby/pull/41) added Hanami helpers
- [#42](https://github.com/castle/castle-ruby/pull/42) added possibility to set do_not_track flag in `Castle::Client` options
- [#48](https://github.com/castle/castle-ruby/pull/48) added failover strategies for `authenticate` method

## 2.3.2

**Bug fixes:**

- fix for outdated Gemfile.lock

## 2.3.0

**Features:**

- extract `client_id` from `HTTP_X_CASTLE_CLIENT_ID` header when not found in cookies

**Enhancements:**

- repository cleanup

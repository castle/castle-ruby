# Changelog

## 9.3.0

- Add `Castle::PaymentRequiredError` for HTTP 402 responses.

## 9.2.0

**Changes:**

- Slim down the default request context to `headers`, `ip` and `library`; the remaining data is already available via `headers`.
- Remove the internal `Castle::ClientId::Extract` service and the now-unused `cookies` plumbing in `Castle::Context::GetDefault`.
- No longer read the API secret from the `CASTLE_API_SECRET` environment variable automatically; set `Castle.api_secret` explicitly (for example `Castle.api_secret = ENV.fetch('CASTLE_API_SECRET')`).

## 9.1.0

**Enhancements:**

- Add Events API support (enterprise) — three new client methods for querying event data:
  - `events_schema` — `GET /v1/events/schema`
  - `query_events` — `POST /v1/events/query`
  - `group_events` — `POST /v1/events/group`

**Housekeeping:**

- Remove unused `Castle::Validators::NotSupported` (dead code)
- Remove unused `Session::HTTPS_SCHEME` constant; inline the comparison in `GetConnection`
- Replace deprecated `:mingw, :x64_mingw` Bundler platforms with `:windows`
- Bump Bundler 2.6.9 → 2.7.2
- Bump json 2.19.5 → 2.19.7

## Unreleased

- Bump dependencies (rack 3.1.19 → 3.2.6, rake, rspec-\*, timecop, simplecov-html, diff-lcs)
- Bump Ruby to 3.4.9 (zlib CVE-2026-27820)
- Bump Node.js to 24.16.0 in `.tool-versions`
- Repair `yarn format:check`: add `syntax_tree` to the dev group (required by `@prettier/plugin-ruby` 4.x), reformat 11 spec files, and disable rubocop cops that conflict with prettier-ruby (`Layout/SpaceInsideHashLiteralBraces`, `Style/EmptyMethod`)

## 9.0.0

**BREAKING CHANGES:**

- Drop support for Ruby < 3.2
- Drop legacy API endpoints and the matching DSL on `Castle::Client`:
  - `Castle::API::Track`, `Castle::Client#track`
  - `Castle::API::Authenticate`, `Castle::Client#authenticate`
  - Device endpoints: `Castle::API::ApproveDevice`, `Castle::API::GetDevice`, `Castle::API::GetDevicesForUser`, `Castle::API::ReportDevice`
  - Impersonation endpoints: `Castle::API::StartImpersonation`, `Castle::API::EndImpersonation`, `Castle::Client#start_impersonation`, `Castle::Client#end_impersonation`
  - Removed `Castle::ImpersonationFailed` error class
- Use `Castle::API::Risk`, `Castle::API::Filter`, `Castle::API::Log` (and the matching `Castle::Client#risk` / `#filter` / `#log` methods) instead.
- Drop `castle/support/hanami` (only ever supported the long-EOL Hanami 1.x architecture) and `castle/support/padrino` (negligible adoption). The 3-line replacement is documented in the README.

**Enhancements:**

- Add `Castle::API::ListItems::CreateBatch` (`POST /v1/lists/{list_id}/items/batch`) and `Castle::Client#create_batch_list_items`
- Add `Castle::API::Privacy::RequestData` and `Castle::API::Privacy::DeleteData` (current `POST` / `DELETE /v1/privacy/users`) plus matching `Castle::Client#request_user_data` / `#delete_user_data` — closes [#261](https://github.com/castle/castle-ruby/issues/261). The deprecated path-based variants are intentionally not exposed.
- Add support for Ruby 3.4 and Rails 8.0 / 8.1. CI matrix runs nine representative Ruby × Rails combinations across Ruby 3.2/3.3/3.4 and Rails 7.0–8.1; see [`.github/workflows/specs.yml`](.github/workflows/specs.yml) for the exact list
- Migrate CI from CircleCI to GitHub Actions (`specs.yml` and `lint.yml`); the dormant CircleCI integration and stale checkout key are removed
- Replace `appraisal` with hand-maintained `gemfiles/*.gemfile` (Rails 7.0, 7.1, 7.2, 8.0, 8.1)
- Switch from RVM-style `.ruby-gemset` to asdf-style `.tool-versions`
- Modernize `.rubocop.yml`: drop deprecated `prettier` inherit, target Ruby 3.2, add `rubocop-rake`
- Drop deprecated `coveralls_reborn`; rely on `simplecov` directly
- Drop `byebug` dev dependency in favor of stdlib `debug`
- Add gem metadata (`source_code_uri`, `changelog_uri`, `bug_tracker_uri`, `rubygems_mfa_required`)
- Drop the dormant Coditsu CI integration

**Bug fixes:**

- Failover handlers in `Castle::API::Risk` / `Filter` / `Log` no longer crash with `NoMethodError` when `options[:user]` is missing — closes [#279](https://github.com/castle/castle-ruby/issues/279). `Filter` additionally falls back to `matching_user_id`.
- The same hardening is applied to the `Castle::Client#filter` / `#risk` / `#log` do-not-track path, which previously crashed with the same shape when tracking was disabled and the payload had no `:user` block.
- A per-call `Castle::Configuration` passed via `Castle::API::Risk.call(payload.merge(config: …))` now correctly drives the underlying HTTP connection (host, port, timeouts, SSL) — previously only the request body honored it while the connection was always built from the global singleton.
- `Castle::Core::GetConnection` now sets both `open_timeout` and `read_timeout` from `request_timeout`, so slow TCP/TLS handshakes hit the configured budget instead of falling back to Net::HTTP's 60 s default.

## 8.1.0

- [#272](https://github.com/castle/castle-ruby/pull/272)
  - Add support for Lists API

## 8.0.0

- [#267](https://github.com/castle/castle-ruby/pull/267)
  - fix issues with non-string values in headers

- [#262](https://github.com/castle/castle-ruby/pull/262)[#268](https://github.com/castle/castle-ruby/pull/268)
  - add 429 RateLimitError

- Bump dependencies
- Add support for Rubies 3.1 and 3.2 and 3.3
- Add support Rails 7

**BREAKING CHANGES:**

- Drop support for Rubies < 2.7 and Rails < 6

## 7.2.0

- [#253](https://github.com/castle/castle-ruby/pull/253)

  - added InvalidRequestTokenError

- [#254](https://github.com/castle/castle-ruby/pull/254)
  - remove X-Castle-\* headers from allowlist

## 7.1.2

- [#247](https://github.com/castle/castle-ruby/pull/247)
  - fixed issue with body as null

## 7.1.1

- [#246](https://github.com/castle/castle-ruby/pull/246)
  - support failover for risk and filter

## 7.1.0 (2021-06-09)

- [#245](https://github.com/castle/castle-ruby/pull/245)
  - removed not needed sdk based validations

## 7.0.0 (2021-06-03)

**BREAKING CHANGES:**

- [#237](https://github.com/castle/castle-ruby/pull/237)
  - remove `identify` and `review` commands - they are no longer supported
  - remove `Castle::Events` - please use [recognized events](https://docs.castle.io/v1/reference/events/) instead

**Enhancements:**

- [#243](https://github.com/castle/castle-ruby/pull/243)
  - add risk, filter and log endpoints
- [#242](https://github.com/castle/castle-ruby/pull/242)
  - correct configuration used by the logger
  - prevent unnecessary calls to the singleton configuration

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

# Castle Ruby SDK

[![Build Status](https://circleci.com/gh/castle/castle-ruby.svg?style=shield&branch=master)](https://circleci.com/gh/castle/castle-ruby)
[![Gem Version](https://badge.fury.io/rb/castle-rb.svg)](https://badge.fury.io/rb/castle-rb)

The official Ruby SDK for [Castle](https://castle.io). Castle analyzes user behavior in web and mobile apps to stop fraud before it happens.

This gem is a thin, dependency-light wrapper around the [Castle HTTP API](https://reference.castle.io). It exposes:

- **Risk Assessment** — `POST /v1/risk`, `POST /v1/filter`
- **Event logging** — `POST /v1/log` (fire-and-forget, no verdict)
- **Lists & List Items** — full CRUD + search
- **Webhook signature verification**

A full list of supported events and the JSON shape of every payload is documented at <https://reference.castle.io>.

## Requirements

- Ruby `>= 3.2`
- A [Castle](https://dashboard.castle.io) API secret

## Installation

Add the gem to your `Gemfile`:

```ruby
gem 'castle-rb'
```

Then:

```sh
bundle install
```

## Quick start

```ruby
require 'castle'

Castle.api_secret = ENV.fetch('CASTLE_API_SECRET')

verdict = Castle::API::Risk.call(
  type: '$login',
  status: '$succeeded',
  request_token: params[:castle_request_token],
  user: { id: '12345', email: 'user@example.com' },
  context: Castle::Context::Prepare.call(request)
)

case verdict[:policy][:action]
when 'deny'      then # block the user
when 'challenge' then # send 2FA / additional verification
else                  # allow
end
```

`Castle::Context::Prepare.call(request)` extracts the IP and the headers Castle needs from a Rack-compatible `request` object. See [Advanced configuration](#advanced-configuration) for how header allow/deny lists and proxy chains are resolved.

## Configuration

The minimal, recommended setup:

```ruby
Castle.configure do |config|
  # Same as `Castle.api_secret = ...`
  config.api_secret = ENV.fetch('CASTLE_API_SECRET')

  # Behavior when Castle's API is unreachable or returns a 5xx.
  # One of: :allow (default), :deny, :challenge, :throw
  config.failover_strategy = :allow

  # Request timeout in milliseconds (default: 1000).
  # `Castle::RequestError` is raised on timeout.
  config.request_timeout = 1000
end
```

### Logging

```ruby
Castle.configure do |config|
  config.logger = Logger.new($stdout)
end
```

The logger only needs to respond to `#info`. Each request and response (with sensitive values stripped) will be logged.

### Multi-environment / multi-tenant

Most apps only need one global config, but you can also build standalone `Castle::Configuration` objects and pass them per call:

```ruby
config = Castle::Configuration.new.tap do |c|
  c.api_secret = ENV.fetch('CASTLE_API_SECRET_TENANT_A')
end

Castle::API::Risk.call(payload.merge(config: config))
```

## Usage

All endpoints are exposed as `Castle::API::<Endpoint>.call(payload)` and return a parsed `Hash`. The same payloads can be sent through `Castle::Client` (created from a Rack request), which automatically attaches request context and a do-not-track flag.

### Risk

Used for evaluating high-risk events such as logins, registrations, password resets, and transactions. Returns a verdict (`policy[:action]`) plus risk scores and signals.

```ruby
Castle::API::Risk.call(
  type: '$login',
  status: '$succeeded',
  request_token: params[:castle_request_token],
  user: { id: '12345', email: 'user@example.com' },
  context: Castle::Context::Prepare.call(request)
)
```

### Filter

Used to block bots and bad traffic early in the chain (typically registration). Same response shape as Risk.

```ruby
Castle::API::Filter.call(
  type: '$registration',
  status: '$attempted',
  request_token: params[:castle_request_token],
  params: { email: 'user@example.com' },
  context: Castle::Context::Prepare.call(request)
)
```

### Log

Fire-and-forget event logging; no verdict is returned. Useful for events that should be visible in the Castle dashboard but don't need a real-time decision.

```ruby
Castle::API::Log.call(
  type: '$profile_update',
  status: '$succeeded',
  user: { id: '12345' },
  context: Castle::Context::Prepare.call(request)
)
```

### Lists & List Items

Lists let you organize users, IPs, transactions, or any custom property and use them in policies as allow/deny lists. The SDK mirrors the [Lists API](https://reference.castle.io#tag/Lists):

```ruby
list = Castle::API::Lists::Create.call(
  name: 'Trusted IPs',
  color: 'green',
  primary_field: 'ip.address'
)

Castle::API::ListItems::Create.call(
  list_id: list[:id],
  primary_value: '1.2.3.4'
)

Castle::API::ListItems::Query.call(
  list_id: list[:id],
  filters: { primary_value: '1.2.3.4' }
)
```

Available namespaces:

- `Castle::API::Lists::{Create, GetAll, Get, Update, Delete, Query}`
- `Castle::API::ListItems::{Create, Get, Query, Count, Update, Archive, Unarchive}`

### Webhook signature verification

Castle signs every webhook with `X-Castle-Signature`. Verify it before trusting the payload:

```ruby
post '/castle/webhooks' do
  Castle::Webhooks::Verify.call(request)
  # signature is valid; proceed
rescue Castle::WebhookVerificationError
  halt 400
end
```

### Framework helpers

Drop-in helpers expose a request-scoped `castle` client:

```ruby
require 'castle/support/rails'    # `castle` available in controllers
require 'castle/support/sinatra'  # `register Sinatra::Castle` for modular apps
require 'castle/support/padrino'  # `castle` available in helpers
require 'castle/support/hanami'   # `include Castle::Hanami`
```

Each helper builds `Castle::Client.from_request(request)` lazily on first access.

## Advanced configuration

The defaults are good for most deployments. The options below only matter if you have a non-trivial proxy chain or strict header policies.

### Header allow/deny lists

By default the SDK sends every HTTP header except `Cookie` and `Authorization`. Castle uses these headers to fingerprint the request, so the broader the better.

```ruby
Castle.configure do |config|
  # Always-blocked headers (in addition to Cookie/Authorization).
  config.denylisted = ['HTTP-X-Internal-Header']

  # Strict allow-list mode. Headers outside the list are sent with
  # scrubbed values, except for User-Agent which is always preserved.
  # We recommend the curated default if you have to use an allow list:
  config.allowlisted = Castle::Configuration::DEFAULT_ALLOWLIST
end
```

Header names are case-insensitive and accept both `_` and `-` as separators. A leading `HTTP_` prefix is stripped automatically.

### Client IP detection

Castle needs the original client IP, not the IP of your proxy or load balancer. The SDK reads `X-Forwarded-For` and `Remote-Addr` by default; pick **one** of the strategies below depending on your infrastructure:

```ruby
Castle.configure do |config|
  # 1. Custom header (e.g. Cloudflare's Cf-Connecting-Ip).
  config.ip_headers = ['Cf-Connecting-Ip']

  # 2. Static, known proxy IPs (strings or regexes).
  config.trusted_proxies = ['10.0.0.1', /\A192\.168\./]

  # 3. Ephemeral proxies but known chain depth.
  config.trusted_proxy_depth = 2

  # 4. Last resort: trust the entire X-Forwarded-For chain.
  # Warning: vulnerable to header spoofing if a malicious proxy is in path.
  config.trust_proxy_chain = false
end
```

Pick **either** `trusted_proxies` **or** `trusted_proxy_depth`, never both. Private/loopback ranges in `Castle::Configuration::TRUSTED_PROXIES` are always considered trusted.

## Errors

All exceptions inherit from `Castle::Error`. The most useful ones:

| Class                              | Raised when                                                   |
| ---------------------------------- | ------------------------------------------------------------- |
| `Castle::ConfigurationError`       | The SDK is misconfigured (missing API secret, bad URL, etc.). |
| `Castle::RequestError`             | Network failure or timeout reaching Castle.                   |
| `Castle::InvalidRequestTokenError` | The `request_token` is missing or invalid.                    |
| `Castle::InvalidParametersError`   | 422 response with validation details.                         |
| `Castle::RateLimitError`           | 429 response — back off and retry.                            |
| `Castle::UnauthorizedError`        | 401 — bad API secret.                                         |
| `Castle::InternalServerError`      | 5xx response from Castle.                                     |
| `Castle::WebhookVerificationError` | Webhook signature did not match.                              |

The full list lives in [`lib/castle/errors.rb`](lib/castle/errors.rb).

## Upgrading to 9.0

`9.0` removes a number of legacy endpoints and DSL methods. If you're upgrading from 8.x:

| Removed                                                                  | Replacement                              |
| ------------------------------------------------------------------------ | ---------------------------------------- |
| `Castle::API::Track` / `Castle::Client#track`                            | `Castle::API::Log` or `Castle::API::Risk` |
| `Castle::API::Authenticate` / `Castle::Client#authenticate`              | `Castle::API::Risk`                       |
| `Castle::API::ApproveDevice` / `GetDevice` / `GetDevicesForUser` / `ReportDevice` | No direct replacement — contact support |
| `Castle::API::StartImpersonation` / `EndImpersonation`                   | No direct replacement — contact support  |
| `Castle::ImpersonationFailed`                                            | Removed                                  |

Minimum supported Ruby is now `3.2`. See [`CHANGELOG.md`](CHANGELOG.md) for the full list.

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/castle/castle-ruby).

```sh
bundle install
bundle exec rspec
bundle exec rubocop
```

To test against a specific Rails version:

```sh
BUNDLE_GEMFILE=gemfiles/rails_8.1.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_8.1.gemfile bundle exec rspec
```

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).

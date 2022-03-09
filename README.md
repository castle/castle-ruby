# Ruby SDK for Castle

[![Build Status](https://circleci.com/gh/castle/castle-ruby.svg?style=shield&branch=master)](https://circleci.com/gh/castle/castle-ruby)
[![Coverage Status](https://coveralls.io/repos/github/castle/castle-ruby/badge.svg?branch=coveralls)](https://coveralls.io/github/castle/castle-ruby?branch=coveralls)
[![Gem Version](https://badge.fury.io/rb/castle-rb.svg)](https://badge.fury.io/rb/castle-rb)

**[Castle](https://castle.io) analyzes user behavior in web and mobile apps to stop fraud before it happens.**

## Installation

Add the `castle-rb` gem to your `Gemfile`

```ruby
gem 'castle-rb'
```

## Configuration

### Framework configuration

Load and configure the library with your Castle API secret in an initializer or similar.

```ruby
Castle.api_secret = 'YOUR_API_SECRET'
```

A Castle client instance will be made available as `castle` in your

- Rails controllers when you add `require 'castle/support/rails'`

- Padrino controllers when you add `require 'castle/support/padrino'`

- Sinatra app when you add `require 'castle/support/sinatra'` (and additionally explicitly add `register Sinatra::Castle` to your `Sinatra::Base` class if you have a modular application)

```ruby
require 'castle/support/sinatra'

class ApplicationController < Sinatra::Base
  register Sinatra::Castle
end
```

- Hanami when you add `require 'castle/support/hanami'` and include `Castle::Hanami` to your Hanami application

```ruby
require 'castle/support/hanami'

module Web
  class Application < Hanami::Application
    include Castle::Hanami
  end
end
```

### Client configuration

```ruby
Castle.configure do |config|
  # Same as setting it through Castle.api_secret
  config.api_secret = 'secret'

  # For authenticate method you can set failover strategies: allow(default), deny, challenge, throw
  config.failover_strategy = :deny

  # Castle::RequestError is raised when timing out in milliseconds (default: 1000 milliseconds)
  config.request_timeout = 1500

  # Base Castle API url
  # config.base_url = "https://api.castle.io/v1"

  # Logger (need to respond to info method) - logs Castle API requests and responses
  # config.logger = Logger.new(STDOUT)

  # Allowlisted and Denylisted headers are case insensitive and allow to use _ and - as a separator, http prefixes are removed
  # Allowlisted headers
  # By default, the SDK sends all HTTP headers, except for Cookie and Authorization.
  # If you decide to use a allowlist, the SDK will:
  # - always send the User-Agent header
  # - send scrubbed values of non-allowlisted headers
  # - send proper values of allowlisted headers.
  # @example
  #   config.allowlisted = ['X_HEADER']
  #   # will send { 'User-Agent' => 'Chrome', 'X_HEADER' => 'proper value', 'Any-Other-Header' => true }
  #
  # We highly suggest using denylist instead of allowlist, so that Castle can use as many data points
  # as possible to secure your users. If you want to use the allowlist, this is the minimal
  # amount of headers we recommend:
  config.allowlisted = Castle::Configuration::DEFAULT_ALLOWLIST

  # Denylisted headers take precedence over allowlisted elements
  # We always denylist Cookie and Authentication headers. If you use any other headers that
  # might contain sensitive information, you should denylist them.
  config.denylisted = ['HTTP-X-header']

  # Castle needs the original IP of the client, not the IP of your proxy or load balancer.
  # The SDK will only trust the proxy chain as defined in the configuration.
  # We try to fetch the client IP based on X-Forwarded-For or Remote-Addr headers in that order,
  # but sometimes the client IP may be stored in a different header or order.
  # The SDK can be configured to look for the client IP address in headers that you specify.

  # Sometimes, Cloud providers do not use consistent IP addresses to proxy requests.
  # In this case, the client IP is usually preserved in a custom header. Example:
  # Cloudflare preserves the client request in the 'Cf-Connecting-Ip' header.
  # It would be used like so: config.ip_headers=['Cf-Connecting-Ip']
  config.ip_headers = []

  # If the specified header or X-Forwarded-For default contains a proxy chain with public IP addresses,
  # then you must choose only one of the following (but not both):
  # 1. The trusted_proxies value must match the known proxy IPs. This option is preferable if the IP is static.
  # 2. The trusted_proxy_depth value must be set to the number of known trusted proxies in the chain (see below).
  # This option is preferable if the IPs are ephemeral, but the depth is consistent.

  # Additionally to make X-Forwarded-For and other headers work better discovering client ip address,
  # and not the address of a reverse proxy server, you can define trusted proxies
  # which will help to fetch proper ip from those headers

  # In order to extract the client IP of the X-Forwarded-For header
  # and not the address of a reverse proxy server, you must define all trusted public proxies
  # you can achieve this by listing all the proxies ip defined by string or regular expressions
  # in the trusted_proxies setting
  config.trusted_proxies = []

  # or by providing number of trusted proxies used in the chain
  config.trusted_proxy_depth = 0

  # note that you must pick one approach over the other.

  # If there is no possibility to define options above and there is no other header that holds the client IP,
  # then you may set trust_proxy_chain = true to trust all of the proxy IPs in X-Forwarded-For
  config.trust_proxy_chain = false
  # *Warning*: this mode is highly promiscuous and could lead to wrongly trusting a spoofed IP if the request passes through a malicious proxy

  # *Note: the default list of proxies that are always marked as "trusted" can be found in: Castle::Configuration::TRUSTED_PROXIES
end
```

### Multi-environment configuration

It is also possible to define multiple configs within one application.

```ruby
# Initialize new instance of Castle::Configuration
config =
  Castle::Configuration.new.tap do |c|
    # and set any attribute
    c.api_secret = 'YOUR_API_SECRET'
  end
```

After a successful setup, you can pass the config to any API command as follows:

```ruby
::Castle::API::GetDevice.call(device_token: device_token, config: config)
```

## Usage

See [documentation](https://docs.castle.io/docs/) for how to use this SDK with the Castle APIs

## Exceptions

`Castle::Error` will be thrown if the Castle API returns a 400 or a 500 level HTTP response.
You can also choose to catch a more [finegrained error](https://github.com/castle/castle-ruby/blob/master/lib/castle/errors.rb).

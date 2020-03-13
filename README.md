# Ruby SDK for Castle

[![Build Status](https://travis-ci.org/castle/castle-ruby.svg?branch=master)](https://travis-ci.org/castle/castle-ruby)
[![Coverage Status](https://coveralls.io/repos/github/castle/castle-ruby/badge.svg?branch=coveralls)](https://coveralls.io/github/castle/castle-ruby?branch=coveralls)
[![Gem Version](https://badge.fury.io/rb/castle-rb.svg)](https://badge.fury.io/rb/castle-rb)

**[Castle](https://castle.io) analyzes device, location, and interaction patterns in your web and mobile apps and lets you stop account takeover attacks in real-time..**

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

* Rails controllers when you add `require 'castle/support/rails'`

* Padrino controllers when you add `require 'castle/support/padrino'`

* Sinatra app when you add `require 'castle/support/sinatra'` (and additionally explicitly add `register Sinatra::Castle` to your `Sinatra::Base` class if you have a modular application)

```ruby
require 'castle/support/sinatra'

class ApplicationController < Sinatra::Base
  register Sinatra::Castle
end
```

* Hanami when you add `require 'castle/support/hanami'` and include `Castle::Hanami` to your Hanami application

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

  # Castle::RequestError is raised when timing out in milliseconds (default: 500 milliseconds)
  config.request_timeout = 2000

  # Whitelisted and Blacklisted headers are case insensitive and allow to use _ and - as a separator, http prefixes are removed
  # Whitelisted headers
  # By default, the SDK sends all HTTP headers, except for Cookie and Authorization.
  # If you decide to use a whitelist, the SDK will:
  # - always send the User-Agent header
  # - send scrubbed values of non-whitelisted headers
  # - send proper values of whitelisted headers.
  # @example
  #   config.whitelisted = ['X_HEADER']
  #   # will send { 'User-Agent' => 'Chrome', 'X_HEADER' => 'proper value', 'Any-Other-Header' => true }
  #
  # We highly suggest using blacklist instead of whitelist, so that Castle can use as many data points
  # as possible to secure your users. If you want to use the whitelist, this is the minimal
  # amount of headers we recommend:
  config.whitelisted = Castle::Configuration::DEFAULT_WHITELIST

  # Blacklisted headers take precedence over whitelisted elements
  # We always blacklist Cookie and Authentication headers. If you use any other headers that
  # might contain sensitive information, you should blacklist them.
  config.blacklisted = ['HTTP-X-header']

  # Castle needs the original IP of the client, not the IP of your proxy or load balancer.
  # we try to fetch proper ip based on X-Forwarded-For, X-Client-Id or Remote-Addr headers in that order
  # but sometimes proper ip may be stored in different header or order could be different.
  # SDK can extract ip automatically in that case too, but you have to configure it ip_headers 
  # which you would like to use in the first place
  configuration.ip_headers = []

  # Additionally to make X-Forwarded-For or X-Client-Id work better discovering client ip address,
  # and not the address of a reverse proxy server, you can define trusted proxies
  # which will help to fetch proper ip from those headers
  configuration.trusted_proxies = []
  # *Note: proxies list can be provided as an array of regular expressions
  # *Note: default always marked as trusty list is here: Castle::Configuration::TRUSTED_PROXIES
end
```

## Event Context

The client will automatically configure the context for each request.

### Overriding Default Context Properties

If you need to modify the event context properties or if you desire to add additional properties such as user traits to the context, you can pass the properties in as options to the method of interest. An example:
```ruby
request_context = ::Castle::Client.to_context(request)
track_options = ::Castle::Client.to_options({
  event: '$login.succeeded',
  user_id: user.id,
  properties: {
    key: 'value'
  },
  user_traits: {
    key: 'value'
  }
})
```

## Tracking

Here is a simple example of a track event.

```ruby
begin
  castle.track(
    event: '$login.succeeded',
    user_id: user.id
  )
rescue Castle::Error => e
  puts e.message
end
```

## Signature

`Castle::SecureMode.signature(user_id)` will create a signed user_id.

## Async tracking

By default Castle sends requests synchronously. To eg. use Sidekiq to send requests in a background worker you can pass data to the worker:

#### castle_tracking_worker.rb

```ruby
class CastleTrackingWorker
  include Sidekiq::Worker

  def perform(context, track_options = {})
    client = ::Castle::Client.new(context)
    client.track(track_options)
  end
end
```

#### tracking_controller.rb

```ruby
request_context = ::Castle::Client.to_context(request)
track_options = ::Castle::Client.to_options({
  event: '$login.succeeded',
  user_id: user.id,
  properties: {
    key: 'value'
  },
  user_traits: {
    key: 'value'
  }
})
CastleTrackingWorker.perform_async(request_context, track_options)
```

## Impersonation mode

https://castle.io/docs/impersonation_mode

## Exceptions

`Castle::Error` will be thrown if the Castle API returns a 400 or a 500 level HTTP response. You can also choose to catch a more [finegrained error](https://github.com/castle/castle-ruby/blob/master/lib/castle/errors.rb).

## Documentation

[Official Castle docs](https://castle.io/docs)

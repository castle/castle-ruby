# Ruby SDK for Castle

[![Build Status](https://travis-ci.org/castle/castle-ruby.png)](https://travis-ci.org/castle/castle-ruby)
[![Gem Version](https://badge.fury.io/rb/castle-rb.png)](http://badge.fury.io/rb/castle-rb)
[![Dependency Status](https://gemnasium.com/castle/castle-ruby.png)](https://gemnasium.com/castle/castle-ruby)

**[Castle](https://castle.io) adds real-time monitoring of your authentication stack, instantly notifying you and your users on potential account hijacks.**

## Installation

Add the `castle-rb` gem to your `Gemfile`

```ruby
gem 'castle-rb'
```

Load and configure the library with your Castle API secret in an initializer or similar.

```ruby
Castle.api_secret = 'YOUR_API_SECRET'
```

A Castle client instance will be made available as `castle` in your

* Rails controllers when you add `require 'castle/support/rails'`

* Padrino controllers when you add `require 'castle/support/padrino'`

* Sinatra when you add `require 'castle/support/sinatra'`

The client will automatically configure the [request context](https://api.castle.io/docs#request-context) for each request.

## Documentation

[Official Castle docs](https://castle.io/docs)

## Exceptions

`Castle::Error` will be thrown if the Castle API returns a 400 or a 500 level HTTP response. You can also choose to catch a more [finegrained error](https://github.com/castle/castle-ruby/blob/master/lib/castle/errors.rb).

```ruby
begin
  castle.track(
    name: '$login.succeeded',
    user_id: user.id)
rescue Castle::Error => e
  puts e.message
end
```

## Configuration

```ruby
Castle.configure do |config|
  # Same as setting it through Castle.api_secret
  config.api_secret = 'secret'

  # Castle::RequestError is raised when timing out (default: 30.0)
  config.request_timeout = 2.0

  # For tracking in non-web environments: https://castle.io/docs/sources (default: 'web')
  config.source_header = 'backend'

  # Whitelisted and Blacklisted headers are case insensitive and allow to use _ and - as a separator, http prefixes are removed
  # Whitelisted headers
  config.whitelisted = ['X_HEADER']
  # or append to default
  config.whitelisted += ['http-x-header']

  # Blacklisted headers 
  config.blacklisted = ['HTTP-X-header'] 
  # or append to default
  config.blacklisted += ['X_HEADER']

  # blacklisted headers take advantage over whitelisted elements
end
```


## Signature

`Castle::SecureMode.signature(user_id)` will create a signed user_id.

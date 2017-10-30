# Ruby SDK for Castle

[![Build Status](https://travis-ci.org/castle/castle-ruby.svg?branch=master)](https://travis-ci.org/castle/castle-ruby)
[![Coverage Status](https://coveralls.io/repos/github/castle/castle-ruby/badge.svg?branch=coveralls)](https://coveralls.io/github/castle/castle-ruby?branch=coveralls)
[![Gem Version](https://badge.fury.io/rb/castle-rb.svg)](https://badge.fury.io/rb/castle-rb)
[![Dependency Status](https://gemnasium.com/badges/github.com/castle/castle-ruby.svg)](https://gemnasium.com/github.com/castle/castle-ruby)

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

* Sinatra app when you add `require 'castle/support/sinatra'` (and additionally explicitly add `register Sinatra::Castle` to your `Sinatra::Base` class if you have a modular application)

```
require 'castle/support/sinatra'

class ApplicationController < Sinatra::Base
  register Sinatra::Castle
end
```

* Hanami when you add `require 'castle/support/hanami'` and include `Castle::Hanami` to your Hanami application

```
require 'castle/support/hanami'

module Web
  class Application < Hanami::Application
    include Castle::Hanami
  end
end
```

The client will automatically configure the [request context](https://api.castle.io/docs#request-context) for each request.

## Documentation

[Official Castle docs](https://castle.io/docs)

## Exceptions

`Castle::Error` will be thrown if the Castle API returns a 400 or a 500 level HTTP response. You can also choose to catch a more [finegrained error](https://github.com/castle/castle-ruby/blob/master/lib/castle/errors.rb).

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

## Configuration

```ruby
Castle.configure do |config|
  # Same as setting it through Castle.api_secret
  config.api_secret = 'secret'

  # For authenticate method you can set failover strategies: allow(default), deny, challenge, throw
  config.failover_strategy = :deny

  # Castle::RequestError is raised when timing out in seconds (default: 500 milliseconds)
  config.request_timeout = 2000

  # Whitelisted and Blacklisted headers are case insensitive and allow to use _ and - as a separator, http prefixes are removed
  # Whitelisted headers
  config.whitelisted = ['X_HEADER']
  # or append to default
  config.whitelisted += ['http-x-header']

  # Blacklisted headers take advantage over whitelisted elements
  config.blacklisted = ['HTTP-X-header']
  # or append to default
  config.blacklisted += ['X_HEADER']
end
```


## Signature

`Castle::SecureMode.signature(user_id)` will create a signed user_id.

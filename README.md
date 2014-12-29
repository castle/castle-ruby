# Ruby SDK for Userbin

[![Build Status](https://travis-ci.org/userbin/userbin-ruby.png)](https://travis-ci.org/userbin/userbin-ruby)
[![Gem Version](https://badge.fury.io/rb/userbin.png)](http://badge.fury.io/rb/userbin)
[![Dependency Status](https://gemnasium.com/userbin/userbin-ruby.png)](https://gemnasium.com/userbin/userbin-ruby)
[![Coverage Status](https://coveralls.io/repos/userbin/userbin-ruby/badge.png)](https://coveralls.io/r/userbin/userbin-ruby)

**[Userbin](https://userbin.com) adds real-time monitoring of your authentication stack, instantly notifying you and your users on potential account hijacks.**

## Installation

Add the `userbin` gem to your `Gemfile`

```ruby
gem 'userbin'
```

Load and configure the library with your Userbin API secret in an initializer or similar.

```ruby
Userbin.api_secret = 'YOUR_API_SECRET'
```

A Userbin client instance will automatically be made available as `userbin` in your Rails, Sinatra or Padrino controllers.

## Tracking security events

`track` lets you record the security-related actions your users perform. The more actions you track, the more accurate Userbin is in identifying fraudsters.

When you have access to a logged in user, send along the same user identifier as when you initiated Userbin.js.

```ruby
userbin.track(
  user_id: user.id,
  name: 'login.succeeded')
```

If you don't have access to a logged in user just omit `user_id`, typically when tracking failed logins.

```ruby
userbin.track(name: 'login.failed')
```

All the available events are:

- `login.succeeded`
- `login.failed`
- `logout.succeeded`

## Configuration

```ruby
Userbin.configure do |config|
  # Same as setting it through Userbin.api_secret
  config.api_secret = 'secret'

  # Userbin::RequestError is raised when timing out (default: 30.0)
  config.request_timeout = 2.0
end
```

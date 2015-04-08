# Ruby SDK for Castle

[![Build Status](https://travis-ci.org/castle/castle-ruby.png)](https://travis-ci.org/castle/castle-ruby)
[![Gem Version](https://badge.fury.io/rb/castle.png)](http://badge.fury.io/rb/castle)
[![Dependency Status](https://gemnasium.com/castle/castle-ruby.png)](https://gemnasium.com/castle/castle-ruby)
[![Coverage Status](https://coveralls.io/repos/castle/castle-ruby/badge.png)](https://coveralls.io/r/castle/castle-ruby)

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

A Castle client instance will automatically be made available as `castle` in your Rails, Sinatra or Padrino controllers.

## Tracking security events

`track` lets you record the security-related actions your users perform. The more actions you track, the more accurate Castle is in identifying fraudsters.

Event names and detail properties that have semantic meaning are prefixed `$`, and we handle them in special ways.

When you have access to a **logged in user**, set `user_id` to the same user identifier as when you initiated Castle.js.

```ruby
castle.track(
  name: '$login.succeeded',
  user_id: user.id)
```

When you **don't** have access to a logged in user just omit `user_id`, typically when tracking `$login.failed` and `$password_reset.requested`. Instead, whenever you have access to the user-submitted form value, add this to the event details as `$login`.

```ruby
castle.track(
  name: '$login.failed',
  details: {
    '$login' => 'johan@castle.io'
  })
```

### Supported events

- `$login.succeeded`: Record when a user attempts to log in.
- `$login.failed`: Record when a user logs out.
- `$logout.succeeded`:  Record when a user logs out.
- `$registration.succeeded`: Capture account creation, both when a user signs up as well as when created manually by an administrator.
- `$registration.failed`: Record when an account failed to be created.
- `$password_reset.requested`: An attempt was made to reset a user’s password.
- `$password_reset.succeeded`: The user completed all of the steps in the password reset process and the password was successfully reset. Password resets **do not** required knowledge of the current password.
- `$password_reset.failed`: Use to record when a user failed to reset their password.
- `$password_change.succeeded`: Use to record when a user changed their password. This event is only logged when users change their **own** password.
- `$password_change.failed`:  Use to record when a user failed to change their password.

### Supported detail properties

- `$login`: The submitted email or username from when the user attempted to log in or reset their password. Useful when there is no `user_id` available.

## Secure mode

Avoid client-side spoofing by having your backend sign the user data with `secure_encode`.

```erb
_castle('setUser', '<%= Castle.secure_encode({
  id: current_user.id,
  email: current_user.email }) %>');
```

This will use your API Secret to encode the data into [JWT](http://jwt.io) format, for example:

```javascript
_castle('setUser', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1...y4PCIXrz1Ejs');
```

**Important:** Make sure you enable **Secure mode** in the [Castle dashboard](https://dashboard.castle.io/settings/general).

## Exceptions

`Castle::Error` will be thrown if the Castle API returns a 400 or a 500 level HTTP response. You can also choose to catch a more [finegrained error](https://github.com/castle/castle-ruby/blob/master/lib/castle-rb/errors.rb).

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
end
```

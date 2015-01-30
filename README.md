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

Event names and detail properties that have semantic meaning are prefixed `$`, and we handle them in special ways.

When you have access to a **logged in user**, set `user_id` to the same user identifier as when you initiated Userbin.js.

```ruby
userbin.track(
  name: '$login.succeeded',
  user_id: user.id)
```

When you **don't** have access to a logged in user just omit `user_id`, typically when tracking `$login.failed` and `$password_reset.requested`. Instead, whenever you have access to the user-submitted form value, add this to the event details as `$login`.

```ruby
userbin.track(
  name: '$login.failed',
  details: {
    '$login' => 'johan@userbin.com'
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

## Configuration

```ruby
Userbin.configure do |config|
  # Same as setting it through Userbin.api_secret
  config.api_secret = 'secret'

  # Userbin::RequestError is raised when timing out (default: 30.0)
  config.request_timeout = 2.0
end
```

# Ruby SDK for Userbin

[![Build Status](https://travis-ci.org/userbin/userbin-ruby.png)](https://travis-ci.org/userbin/userbin-ruby)
[![Gem Version](https://badge.fury.io/rb/userbin.png)](http://badge.fury.io/rb/userbin)
[![Dependency Status](https://gemnasium.com/userbin/userbin-ruby.png)](https://gemnasium.com/userbin/userbin-ruby)


[Userbin](https://userbin.com) provides an additional security layer to your application by adding user activity monitoring, real-time threat protection and two-factor authentication in a white-label package. Your users **do not** need to be signed up or registered for Userbin before using the service and there's no need for them to download any proprietary apps. Also, Userbin requires **no modification of your current database schema** as it uses your local user IDs.

## Table of Contents

- [Getting Started](#getting-started)
- [Setup User Monitoring](#setup-user-monitoring)
- [Active Sessions](#active-sessions)
- [Security Events](#security-events)
- [Two-factor Authentication](#two-factor-authentication)
  - [Pairing with Google Authenticator](#pairing-with-google-authenticator)
  - [Pairing with Phone Number (SMS)](#pairing-with-phone-number-sms)
  - [Pairing with YubiKey](#pairing-with-yubikey)
  - [Enabling and Disabling](#enabling-and-disabling)
  - [Authenticating](#authenticating)
  - [Backup Codes](#backup-codes)
  - [List Pairings](#list-pairings)

## Getting Started

Add the `userbin` gem to your `Gemfile`

```ruby
gem "userbin"
```

Install the gem

```bash
bundle install
```

Load and configure the library with your Userbin API secret in an initializer or similar.

```ruby
require 'userbin'
Userbin.api_secret = "YOUR_API_SECRET"
```

Add a reference to the Userbin client in your main controller so that it's globally accessible throughout a request. The initializer takes a Rack request as argument from which it extracts details such as IP address and user agent and sends it along all API requests.

```ruby
class ApplicationController < ActionController::Base
  def userbin
    @userbin ||= Userbin::Client.new(request)
  end
  # ...
end
```

## Setup User Monitoring

You should call `login` as soon as the user has logged in to your application. Pass a unique user identifier, and an *optional* hash of user properties which are used when searching for users in your dashboard. This will create a [Session](https://api.userbin.com/#POST--version-users--user_id-sessions---format-) resource and return a corresponding [session token](https://api.userbin.com/#session-tokens) which is stored in the Userbin client.

```ruby
def your_after_login_hook
  userbin.login(current_user.id, email: current_user.email)
end
```

Once logged in to Userbin, all requests made through the Userbin instance are on behalf of the currently logged in user.

When a user logs out from within your application, call `logout` to remove the session from the user's [active sessions](#active-sessions).

```ruby
def your_after_logout_hook
  userbin.logout
end
```

The real magic happens when you use `authorize!` to control access to only those logged in to Userbin, which is probably everywhere you allow authenticated users. This makes sure that the session token created by `login` is valid and up to date, and raises `UserUnauthorizedError` if it's not. Reasons for this include being automatically locked down due to suspicious behavior or the session being remotely revoked.

**Note:** The session token will be [refreshed](https://api.userbin.com/#monitoring) every 5 minutes. This means that even though a session becomes invalid, no exceptions will be generated until the next refresh. E.g. revoking a session from the dashboard might take up to 5 minutes to happen.

```ruby
class AccountController < ApplicationController
  before_filter :authenticate_user! # from e.g. Devise
  before_filter { userbin.authorize! }
  # ...
end
```

You should catch these errors in one place and log out the authenticated user.

```ruby
class ApplicationController < ActionController::Base
  rescue_from Userbin::UserUnauthorizedError do |e|
    sign_out # log out your user locally
    redirect_to root_url
  end
end
```



**That's it!** Now log in to your application and watch your user appear in the [Userbin dashboard](https://dashboard.userbin.com).

## Active Sessions

Show a list of sessions currently signed to a user's account.

The *context* is from the last recorded [security event](#security-events) on a session.

```ruby
userbin.sessions.each do |session|
  puts session.id          # => 'yt9BkoHzcQoou4jqbQbJUqqMdxyxvCBr'
  puts session.context.ip  # => '88.12.129.1'
end
```

Destroy a session to revoke access and trigger a `UserUnauthorizedError` the next time `authorize!` refreshes the session token, which is within 5 minutes.

```ruby
userbin.sessions.destroy('yt9BkoHzcQoou4jqbQbJUqqMdxyxvCBr')
```

## Security Events

List a user's recent account activity, which include security events such as user logins and failed two-factor attempts. See the [Event API](https://api.userbin.com/#events) for a list of all the available events.

```ruby
userbin.events.each do |event|
  puts event.name                        # => 'session.created'
  puts event.context.ip                  # => '88.12.129.1'
  puts event.context.location.country    # => 'Sweden'
  puts event.context.user_agent.browser  # => 'Chrome'
end
```

## Two-factor Authentication

Using two-factor authentication involves two steps: **pairing** and **authenticating**.

### Pairing

Before your users can protect their account with two-factor authentication, they will need to pair their their preferred way of authenticating. The [Pairing API](https://api.userbin.com/#pairings) lets users add, verify, and remove authentication channels. Only *verified* pairings are valid for authentication.

#### Pairing with Google Authenticator

The user visits a page to add Google Authenticator to their account. First create a new Authenticator pairing to generate a QR code image.

```ruby
@authenticator = userbin.pairings.create(type: 'authenticator')
```

Render a page containing the QR code, which the user scans with Google Authenticator.

```erb
<img src="<%= @authenticator[:qr_url] %>">
```

After scanning the QR code, the user will enter the 6 digit token that Google Authenticator displays, and submit the form. Capture the response and verify the pairing.

```ruby
begin
  userbin.pairings.verify(params[:pairing_id], response: params[:code])
rescue Userbin::InvalidParametersError
  flash.notice = 'Wrong code, try again'
end
```

#### Pairing with Phone Number (SMS)

Create a new phone number pairing which will send out a verification SMS.

```ruby
@phone_number = userbin.pairings.create(
  type: 'phone_number', number: '+1739855455')
```

Catch the code from the user to pair the phone number.

```ruby
begin
  userbin.pairings.verify(params[:pairing_id], response: params[:code])
rescue Userbin::InvalidParametersError
  flash.notice = 'Wrong code, try again'
end
```

#### Pairing with YubiKey

YubiKeys are immediately verified for two-factor authentication.

```ruby
begin
  userbin.pairings.create(type: 'yubikey', otp: params[:code])
rescue Userbin::InvalidParametersError
  flash.notice = 'Wrong code, try again'
end
```

#### Enabling and Disabling

For the sake of flexibility, two-factor authentication isn't enabled automatically when you add your first pairing.

```ruby
userbin.enable_mfa
userbin.disable_mfa
```

### Authenticating

If the user has enabled two-factor authentication, `authorize!` might raise `ChallengeRequiredError`, which means they'll have to verify a challenge to proceed.

Capture this error just as with UserUnauthorizedError and redirect the user.

If the user tries to reach a path protected by `authorize!` after a challenge has been created but still not verified, the session will be destroyed and UserUnauthorizedError raised.

```ruby
class ApplicationController < ActionController::Base
  rescue_from Userbin::ChallengeRequiredError do |exception|
    redirect_to show_challenge_path
  end
  # ...
end
```

Create a challenge, which will send the user and SMS if this is the default pairing. After the challenge has been verified, `authorize!` will not throw any further exceptions until any suspicious behavior is detected.

```ruby
class ChallengeController < ApplicationController
  def show
    @challenge = userbin.challenges.create
  end

  def verify
    challenge_id = params.require(:challenge_id)
    code = params.require(:code)

    userbin.challenges.verify(challenge_id, response: code)

    # Yay, the challenge was verified!
    redirect_to root_url

  rescue Userbin::ForbiddenError => e
    flash.notice = 'Wrong code, bye!'
    raise Userbin::UserUnauthorizedError.new(e) # trigger the global handler
  end
end
```

### Backup Codes

List or generate new backup codes used for when the user didn't bring their authentication device.

```ruby
userbin.backup_codes
userbin.generate_backup_codes(count: 8)
```

### List Pairings

List all pairings.

```ruby
# List all pairings
userbin.pairings.each do |pairing|
  puts pairing.id      # => 'yt9BkoHzcQoou4jqbQbJUqqMdxyxvCBr'
  puts pairing.type    # => 'authenticator'
  puts pairing.default # => true
end
```

Set a pairing as the default one.

```ruby
userbin.pairings.set_default('yt9BkoHzcQoou4jqbQbJUqqMdxyxvCBr')
```

Remove a pairing. If you remove the default pairing, two-factor authentication will be disabled.

```ruby
userbin.pairings.destroy('yt9BkoHzcQoou4jqbQbJUqqMdxyxvCBr')
```


## Configuration

```ruby
Userbin.configure do |config|
  # Same as setting it through Userbin.api_secret
  config.api_secret = 'secret'

  # Userbin::RequestError is raised when timing out (default: 2.0)
  config.request_timeout = 2.0
end
```

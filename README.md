# Ruby SDK for Userbin

[![Build Status](https://travis-ci.org/userbin/userbin-ruby.png)](https://travis-ci.org/userbin/userbin-ruby)
[![Gem Version](https://badge.fury.io/rb/userbin.png)](http://badge.fury.io/rb/userbin)
[![Dependency Status](https://gemnasium.com/userbin/userbin-ruby.png)](https://gemnasium.com/userbin/userbin-ruby)


[Userbin](https://userbin.com) provides an additional security layer to your application by adding user activity monitoring, real-time threat protection and two-factor authentication in a white-label package. Your users **do not** need to be signed up or registered for Userbin before using the service and there's no need for them to download any proprietary apps. Also, Userbin requires **no modification of your current database schema** as it uses your local user IDs.

### Using Devise?

If you're using [Devise](https://github.com/plataformatec/devise) for authentication, check out the **[Userbin extension for Devise](https://github.com/userbin/devise_userbin)** for an even easier integration.

## Getting started

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

Add a reference it to your ApplicationController or similar so that it's globally accessible throughout a request. A new instance needs to be created for every request.

```ruby
class ApplicationController < ActionController::Base
  def userbin
    @userbin ||= Userbin::Client.new(request)
  end
  # ...
end
```

## Tracking user sessions

You should call `login` as soon as the user has logged in to your application. Pass a unique user identifier, and an optional hash of user properties which are used when searching for users in your dashboard.

```ruby
def after_login_hook
  userbin.login(current_user.id, email: current_user.email)
end
```

When a user logs out from within your application, call `logout` so the session is removed from the user's active sessions.

```ruby
def after_logout_hook
  userbin.logout
end
```

Use `authorize!` to control access to only those logged in to Userbin. This makes sure that the session token created by `login` is valid and up to date, and raises `Userbin::UserUnauthorizedError` if it's not. The session token will be refreshed once every 5 minutes.

```ruby
before_filter do
  userbin.authorize!
end
```

At any time, a call to Userbin might result in an exception, maybe because the user has been logged out. You should catch these errors in one place and take action.

```ruby
class ApplicationController < ActionController::Base
  rescue_from Userbin::UserUnauthorizedError do |e|
    sign_out # log out your user locally
    redirect_to root_url
  end
end
```

**Verify that it works:** Log in to your application and watch a user appear in the [Userbin dashboard](https://dashboard.userbin.com).


## Configuring two-factor authentication

### Pairing

The Pairing API lets users add, verify, and remove authentication devices. Google Authenticator, YubiKey

#### Google Authenticator

Create a new Authenticator pairing to get hold of the QR code image to show to the user.

```ruby
authenticator = userbin.pairings.create(type: 'authenticator')

puts authenticator.qr_url # => "http://..."
```

Catch the code from the user to pair the Authenticator app.

```ruby
authenticator = userbin.pairings.build(id: params[:pairing_id])

begin
  authenticator.verify(response: params[:code])
rescue
  flash.notice = 'Wrong code, try again'
end
```

#### YubiKey

YubiKeys are immediately verified for two-factor authentication.

```ruby
begin
  userbin.pairings.create(type: 'yubikey', otp: code)
rescue
  flash.notice = 'Wrong code, try again'
end
```

#### SMS

Create a new phone number pairing which will send out a verification SMS.

```ruby
phone_number = userbin.pairings.create(
  type: 'phone_number', number: '+1739855455')
```

Catch the code from the user to pair the phone number.

```ruby
phone_number = userbin.pairings.build(id: params[:pairing_id])

begin
  phone_number.verify(response: params[:code])
rescue
  flash.notice = 'Wrong code, try again'
end
```


### Usage

#### 1. Protect routes

If the user has enabled two-factor authentication, `two_factor_authenticate!` will return the second factor that is used to authenticate. If SMS is used, this call will also send out an SMS to the user's registered phone number.

```ruby
class UsersController < ApplicationController
  before_filter :authenticate_with_userbin!

  # Your controller code here

  private
  def authenticate_with_userbin!
    begin
      # Checks if two-factor authentication is needed. Returns nil if not.
      factor = userbin.two_factor_authenticate!

      # Show form and message specific to the current factor
      case factor
      when :authenticator
        redirect_to '/verify/authenticator'
      when :sms
        redirect_to '/verify/sms'
      end
    rescue Userbin::Error
      # logged out from Userbin; clear your current_user and logout
    end
  end
end
```

#### 2. Show the two-factor authentication form to the user

```html
<p>
  Open the two-factor authentication app on your device to view your
  authentication code and verify your identity.
</p>
<form action="/users/handle_two_factor_response" method="post">
  <label for="code">Authentication code</label>
  <input id="code" name="code" type="text" />
  <input type="submit" value="Verify code" />
</form>
```

#### 3. Verify the code from the user

The user enters the authentication code in the form and posts it to your handler.

```ruby
def handle_two_factor_response
  # Get the authentication code from the form
  authentication_code = params[:code]

  begin
    userbin.two_factor_verify(authentication_code)
  rescue Userbin::UserUnauthorizedError
    # invalid code, show the form again
  rescue Userbin::ForbiddenError
    # no tries remaining, log out
  rescue Userbin::Error
    # logged out from Userbin; clear your current_user and logout
  end

  # We made it through two-factor authentication!
end
```

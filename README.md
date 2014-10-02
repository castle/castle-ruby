# Ruby SDK for Userbin

[![Build Status](https://travis-ci.org/userbin/userbin-ruby.png)](https://travis-ci.org/userbin/userbin-ruby)
[![Gem Version](https://badge.fury.io/rb/userbin.png)](http://badge.fury.io/rb/userbin)
[![Dependency Status](https://gemnasium.com/userbin/userbin-ruby.png)](https://gemnasium.com/userbin/userbin-ruby)


[Userbin](https://userbin.com) provides an additional security layer to your application by adding user activity monitoring, real-time threat protection and two-factor authentication in a white-label package. Your users **do not** need to be signed up or registered for Userbin before using the service and there's no need for them to download any proprietary apps. Also, Userbin requires **no modification of your current database schema** as it uses your local user IDs.

<!-- Your users can now easily activate two-factor authentication, configure the level of security in terms of monitoring and notifications and take action on suspicious behaviour. These settings are available as a per-user security settings page which is easily customized to fit your current layout. -->

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

## The basics

First you'll need to initialize a Userbin client for every incoming HTTP request and preferrably add it to the environment so that it's accessible during the request lifetime.

```ruby
env['userbin'] = Userbin::Client.new(request)
```

At any time, a call to Userbin might result in an exception, maybe because the user has been logged out. You should catch these errors in one place and take action. Just catch and display all Userbin errors for now.

```ruby
class ApplicationController < ActionController::Base
  rescue_from Userbin::Error do |e|
    redirect_to root_url, alert: e.message
  end
end
```

## Tracking user sessions

You should call `login` as soon as the user has logged in to your application. Pass a unique user identifier, and an optional hash of user properties. This starts the Userbin session.

```ruby
def after_login_hook
  env['userbin'].login(current_user.id, email: current_user.email)
end
```

And call `logout` just after the user has logged out from your application. This ends the Userbin session.

```ruby
def after_logout_hook
  env['userbin'].logout
end
```

The session created by login expires typically every 5 minutes and needs to be refreshed with new metadata. This is done by calling authorize. Makes sure that the session hasn't been revoked or locked.

```ruby
before_filter do
  env['userbin'].authorize
end
```

> **Verify that it works:** Log in to your Ruby application and watch a user appear in the [Userbin dashboard](https://dashboard.userbin.com).


## Configuring two-factor authentication

### Pairing

#### Google Authenticator

Create a new Authenticator pairing to get hold of the QR code image to show to the user.

```ruby
authenticator = env['userbin'].pairings.create(type: 'authenticator')

puts authenticator.qr_url # => "http://..."
```

Catch the code from the user to pair the Authenticator app.

```ruby
authenticator = env['userbin'].pairings.build(id: params[:pairing_id])

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
  env['userbin'].pairings.create(type: 'yubikey', otp: code)
rescue
  flash.notice = 'Wrong code, try again'
end
```

#### SMS

Create a new phone number pairing which will send out a verification SMS.

```ruby
phone_number = env['userbin'].pairings.create(
  type: 'phone_number', number: '+1739855455')
```

Catch the code from the user to pair the phone number.

```ruby
phone_number = env['userbin'].pairings.build(id: params[:pairing_id])

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
      factor = env['userbin'].two_factor_authenticate!

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
    env['userbin'].two_factor_verify(authentication_code)
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

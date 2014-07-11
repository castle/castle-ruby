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

Load and configure the library with your Userbin API secret in an initializer or similar

```ruby
require 'userbin'
Userbin.api_secret = "YOUR_API_SECRET"
```

## Monitor a user

First you'll need to **initialize a Userbin client** for every incoming HTTP request and add it to the environment so that it's accessible during the request lifetime.

To **monitor a logged in user**, simply call `authorize!` on the Userbin object. You need to pass the user id, and optionally a hash of user properties, preferrable including at least `email`. This call only result in an HTTP request once every 5 minutes.

### 1. Authorize the current user

```ruby
class ApplicationController < ActionController::Base
  # Define a before filter which is run on all requests
  before_filter :initialize_userbin

  # Your controller code here

  private
  def initialize_userbin
    # Initialize Userbin and add it to the request environment
    env['userbin'] = Userbin::Client.new(request)

    if current_user
      # Optional details for text messages, emails and your dashboard
      user_properties = {
        email: current_user.email, # recommended
        # Add `name`, `username` and `image` for improved experience
      }

      begin
        # This checks against Userbin once every 5 minutes under the hood.
        # The `id` MUST be unique across all your users and roles
        env['userbin'].authorize!(current_user.id, user_properties)
      rescue Userbin::Error
        # Logged out from Userbin; clear your current_user and logout
        # TODO: implement!
      end
    end
  end
end
```

> **Verify that it works:** Log in to your Ruby application with an existing user, and [watch a user appear](https://dashboard.userbin.com/users) in your Userbin dashboard.

### 2. Log out

As a last step, you'll need to **end the Userbin session** when the user logs out from your application.

```ruby
def logout
  # Your code for logging out a user

  # End the Userbin session
  env['userbin'].logout
end
```

> **Verify that it works:** Log out of your Ruby application and watch the number of sessions for the user in your Userbin dashboard return to zero.

## Add a link to the user's security settings

Create a new route where you redirect the user to its security settings page, where they can configure two-factor authentication, revoke suspicious sessions and set up notifications.

```ruby
class UsersController < ApplicationController
  def security_settings
    redirect_to env['userbin'].security_settings_url
  end
end
```

> **Verify that it works:** Log in to your Ruby application and visit your new route. This should redirect to https://security.userbin.com where you'll see that you have one active session. *Don't enable two-factor authentication just yet.*

## Two-factor authentication


### 1. Protect routes

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

> **Verify that it works:** Enable two-factor on your security settings page, followed by a logout and and login to your Ruby application. You should now be redirected to one of the routes in the case statement.

### 2. Show the two-factor authentication form to the user

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

### 3. Verify the code from the user

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

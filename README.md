# Ruby SDK for Userbin

[![Build Status](https://travis-ci.org/userbin/userbin-ruby.png)](https://travis-ci.org/userbin/userbin-ruby)
[![Gem Version](https://badge.fury.io/rb/userbin.png)](http://badge.fury.io/rb/userbin)
[![Dependency Status](https://gemnasium.com/userbin/userbin-ruby.png)](https://gemnasium.com/userbin/userbin-ruby)


[Userbin](https://userbin.com) provides an additional security layer to your application by adding user activity monitoring, real-time threat protection and two-factor authentication in a white-label package. Your users **do not** need to be signed up or registered for Userbin before using the service and there's no need for them to download any proprietary apps. Also, Userbin requires **no modification of your current database schema** as it uses your local user IDs.

<!-- Your users can now easily activate two-factor authentication, configure the level of security in terms of monitoring and notifications and take action on suspicious behaviour. These settings are available as a per-user security settings page which is easily customized to fit your current layout. -->

## Getting started

Add the `userbin` gem to your `Gemfile`

```ruby
gem "userbin"
```

Install the gem

```bash
bundle install
```

Load and configure the library with your Userbin API secret.

```ruby
require 'userbin'
Userbin.api_secret = "YOUR_API_SECRET"
```

## Monitor a user

First you'll need to **initialize a Userbin client** for every incoming HTTP request and add it to the environment so that it's accessible during the request lifetime.

To **monitor a logged in user**, simply call `authorize!` on the Userbin object. You need to pass the user id, and optionally a hash of [user properties](.), preferrable including at least `email`. This call only result in an HTTP request once every 5 minutes.

#### Full example

```ruby
class MyController < ApplicationController
  # Define a before filter
  before_filter :initialize_userbin

  # Your controller code here

  private
  def initialize_userbin
    # initialize Userbin and add it to the request environment
    env['userbin'] = Userbin::Client.new(request)

    if user_signed_in?
      user_properties = {
        email: current_user.email,
        name: current_user.name # optional
      }

      begin
        env['userbin'].authorize!(current_user.id, user_properties)
      rescue Userbin::Error
        # logged out from Userbin; clear your current_user and logout
      end
    end
  end
end
```

As a last step, you'll need to **clear the Userbin session** when the user logs out from your application.

```ruby
  env['userbin'].logout
```

Done! Now log in to your application and watch the user appear in your Userbin dashboard.

## Add a link to the user's security settings

Create a new route where you redirect the user to its security settings page, where they can configure two-factor authentication, revoke suspicious sessions and set up notifications.

```ruby
redirect_to env['userbin'].security_settings_url
```

## Two-factor authentication

If the user has enabled two-factor authentication, `two_factor_authenticate!` will return the second factor that is used to authenticate. If SMS is used, this call will also send out an SMS to the user's registered phone number.

```ruby
factor = env['userbin'].two_factor_authenticate!

case factor
when :authenticator then render 'authenticator_form'
when :sms then render 'sms_form'
end
```

The user enters the authentication code in the form and posts it to your handler.

```ruby
begin
  env['userbin'].two_factor_verify(params[:code])
rescue Userbin::UserUnauthorizedError
  # invalid code, show the form again
rescue Userbin::ForbiddenError
  # no tries remaining, log out
rescue Userbin::Error
  # logged out from Userbin; clear your current_user and logout
end
```

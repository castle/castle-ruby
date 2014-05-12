
[![Build Status](https://travis-ci.org/userbin/userbin-ruby.png)](https://travis-ci.org/userbin/userbin-ruby)
[![Gem Version](https://badge.fury.io/rb/userbin.png)](http://badge.fury.io/rb/userbin)
[![Dependency Status](https://gemnasium.com/userbin/userbin-ruby.png)](https://gemnasium.com/userbin/userbin-ruby)

# Ruby SDK for Userbin

> Using Ruby on Rails? Install [Userbin for Devise](https://github.com/userbin/devise_userbin) for super-quick integration.

This library's purpose is to provide an additional security layer to your application by adding multi-factor authentication, user activity monitoring, and real-time threat protection in a white-label package. Your users **do not** need to be signed up or registered for Userbin before using the service.

Your users can now easily activate two-factor authentication, configure the level of security in terms of monitoring and notifications and take action on suspicious behaviour. These settings are available as a per-user security settings page which is easily customized to fit your current layout.

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

## Authenticate

`authenticate` is the key component of the Userbin API. It lets you tie a user to their actions and record properties about them. Whenever any suspious behaviour is detected or a user gets locked out, a call to `authenticate` may throw an exception which needs to be handled by your application.

You’ll want to `authenticate` a user with any relevant information as soon as the current user object is assigned in your application. The method returns a *session token* that you store in a session or cookie for future reference. Either you use the Userbin session token as the ground truth for the user being logged in, or you can store it separately in tandem with your current session.

#### Example

```ruby

options = {
  properties: {
    email: current_user.email,
    name: current_user.full_name
  },
  context: {
    ip: request.ip,
    user_agent: request.user_agent
  }
}

session_token =
  Userbin.authenticate(session[:userbin], current_user.id, options)

session[:userbin] = session_token
```

#### Arguments

The first argument is a session token from a previous call to `authenticate`. This variable is obviously nil on the very first call, where a HTTP request will be made and a new session created.

The second argument is a locally unique identifier for the logged in user, commonly the `id` field. This is the identifier you'll use further on when querying the user.

- `properties` (Hash, optional) - A Hash of properties you know about the user. See the User reference documentation for available fields and their meaning.
- `context` (Hash, optional) - A Hash specifying the user_agent and ip for the current request.

> Note that every call to `authenticate` **does not** result in an HTTP request. Only the very first call, as well as expired session tokens result in a request. Session tokens expire every 5 minutes.

## Two-factor authentication

Two-factor authentication is available to your users out-of-the-box. By browsing to their security settings page, they're able to configure Google Authenticator and SMS settings, set up a backup phone number, and download their recovery codes.

The session token returned from `authenticate` indicates if two-factor authentication is required from the user once your application asks for it. You can do this immediately after you've called `authenticate`, or you can wait until later. You have complete control over what actions you when you want to require two-factor authentication, e.g. when logging in, changing account information, making a purchase etc.

### Step 1: Prompt the user

`two_factor_authenticate!` acts as a gateway in your application. If the user has enabled two-factor authentication, this method will return the second factor that is used to authenticate. If SMS is used, this call will also send out an SMS to the user's registered phone number.

When `two_factor_authenticate!` returns non-falsy value, you should display the appropriate form to the user, requesting their authentication code.

```ruby
factor = Userbin.two_factor_authenticate!(session[:userbin])

case factor
when :authenticator
  render 'two_factor_authenticator_form'
when :sms
  render 'two_factor_sms_form'
end
```

> Note that this call may return a factor more than once per session since Userbin continously scans for behaviour that would require another round of two-factor authentication, such as the user switching to another IP address or web browser.

### Step 2: Verify the code

The user enters the authentication code in the form and posts it to your handler. The last step is for your application to verify the code with Userbin by calling `verify_code`. The session token will get updated on a successful verification, so you'll need to update it in your local session or cookie.

`code` can be either a code from the Google Authenticator app, an SMS, or one of the user's recovery codes.

```ruby
begin
  session[:userbin] =
    Userbin.verify_code(session[:userbin], params[:code])

  redirect_to logged_in_path
rescue Userbin::UserUnauthorizedError => error
  # invalid code, show the form again
rescue Userbin::Forbidden => error
  # no tries remaining, log out
rescue Userbin::Error => error
  # other error, log out
end
```

## Security page

Every user has access to their security settings, which is a hosted page on Userbin. Here users can configure two-factor authentication, revoke suspicious sessions and set up notifications. The security settings page can be customized to fit your current layout by going to the appearance settings in your Userbin dashboard.

**Important:** Since the generated URL contains a Userbin session token that needs to be up-to-date, it's crucial that you don't use this helper directly in your HTML, but instead create a new route where you redirect to the security settings page.

```ruby
get '/security'
  redirect Userbin.security_settings_url
end
```

## De-authenticate

Whenever a user is logged out from your application, you should inform Userbin about this so that the active session is properly terminated. This prevents the session from being used further on.

```ruby
begin
  token = session.delete(:userbin) # remove the local reference
  Userbin.deauthenticate(token)
rescue Userbin::Error; end
```

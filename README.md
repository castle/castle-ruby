[![Build Status](https://travis-ci.org/userbin/userbin-ruby.png)](https://travis-ci.org/userbin/userbin-ruby)
[![Gem Version](https://badge.fury.io/rb/userbin.png)](http://badge.fury.io/rb/userbin)
[![Dependency Status](https://gemnasium.com/userbin/userbin-ruby.png)](https://gemnasium.com/userbin/userbin-ruby)

Userbin for Ruby
================

Userbin for Ruby adds user authentication, login flows and user management to your **Rails**, **Sinatra** or **Rack** app.

[Userbin](https://userbin.com) provides a set of login, signup, and password reset forms that drop right into your application without any need of styling or writing markup. Connect your users via traditional logins or third party social networks. We take care of linking accounts across networks, resetting passwords, and keeping everything safe and secure.

[Create a free account](https://userbin.com) at Userbin to start accepting users in your application.

Installation
------------

1. Add the `userbin` gem to your `Gemfile`

    ```ruby
    gem "userbin"
    ```

1.  Install the gem

    ```shell
    bundle install
    ```

2.  Configure the Userbin module with the credentials you got from signing up.

    In a Rails app, put the following code into a new file at `config/initializers/userbin.rb`, and in Sinatra put it in your main application file and add `require "userbin"`.

    ```ruby
    Userbin.configure do |config|
      config.app_id = "YOUR_APP_ID"
      config.api_secret = "YOUR_API_SECRET"
    end
    ```

    If you don't configure the `app_id` and `api_secret`, the Userbin module will read the `USERBIN_APP_ID` and `USERBIN_API_SECRET` environment variables. This may come in handy on Heroku.

3.  **Rack/Sinatra apps only**: Activate the Userbin Rack middleware

    ```ruby
    use Userbin::Authentication
    ```


Usage
-----

### Forms

An easy way to integrate Userbin is via the [Widget](https://userbin.com/docs/javascript#widget), which will take care of building forms, validating input and provides a drop-in design that adapts nicely to all devices.

The Widget is fairly high level, so remember that you can still use Userbin with your [own forms](https://userbin.com) if it doesn't fit your use-case.

The following links will open up the Widget with the login or the signup form respectively.

```html
<a class="ub-login">Log in</a>
```

```html
<a class="ub-signup">Sign up</a>
```

The logout link will clear the session and redirect the user back to your root path:

```html
<a class="ub-logout">Log out</a>
```

### The current user

Userbin keeps track of the currently logged in user which can be accessed through the `current_user` property. This automatically taps into libraries such as the authorization solution [CanCan](https://github.com/ryanb/cancan).

```erb
Welcome to your account, <%= current_user.email %>
```

To check if a user is logged in, use `user_logged_in?` (or its alias `user_signed_in?` if you prefer Devise conventions)

```erb
<% if user_logged_in? %>
  You are logged in!
<% end %>
```

**Rack/Sinatra apps only**: Since above helpers aren't available outside Rails, instead use `Userbin.current_user` and `Userbin.user_logged_in?`.

Configuration
-------------

The `Userbin.configure` block supports a range of options additional to the Userbin credentials. None of the following options are mandatory.

### protected_path

By default, Userbin reloads the current page on a successful login. If you set the `protected_path` option, users will be redirected to this path instead.

Once set, this path and any sub-path of it will be protected from unauthenticated users by instead rendering a login form.

```ruby
config.protected_path = '/dashboard'
```

### root_path

By default, Userbin reloads the current page on a successful logout. If you set the `root_path` option, users will be redirected to this path instead.

```ruby
config.root_path = '/login'
```

### create_user and find_user

By default, `current_user` will reference a *limited* Userbin profile, enabling you to work without a database. If you override the functions `create_user` and `find_user`, the current user will instead reference one of your models. The `profile` object is an *extended* Userbin profile. For more information about the available attributes in the profile see the [Userbin profile](https://userbin.com/docs/concepts) documentation.

```ruby
config.create_user = Proc.new { |profile|
  User.create! do |user|
    user.userbin_id = profile.id
    user.email      = profile.email
    user.photo      = profile.image
  end
}

config.find_user = Proc.new { |userbin_id|
  User.find_by_userbin_id(userbin_id)
}
```

You'll need to migrate your users and add a reference to the Userbin profile:

```ruby
rails g migration AddUserbinIdToUsers userbin_id:integer:index
```

### skip_script_injection

By default, the Userbin middleware will automatically insert a `<script>` tag before the closing `</body>` in your HTML files in order to handle forms, sessions and user tracking. This script loads everything asynchronously, so it won't affect your page load speed. However if you want to have control of this procedure, set `skip_script_injection` to true and initialize the library yourself. To do that, checkout the [Userbin.js configuration guide](https://userbin.com/docs/javascript#configuration).

```ruby
config.skip_script_injection = true
```


Further configuration and customization
---------------------------------------

Your Userbin dashboard gives you access to a range of functionality:

- Configure the appearance of the login widget to feel more integrated with your service
- Connect 10+ OAuth providers like Facebook, Github and Google.
- Use Markdown to generate mobile-ready transactional emails
- Invite users to your application
- See who is logging in and when
- User management: block, remove and impersonate users
- Export all your user data from Userbin


Documentation
-------------
For complete documentation go to [userbin.com/docs](https://userbin.com/docs)

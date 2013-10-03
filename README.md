Userbin for Ruby
================

Userbin for Ruby adds user authentication, login flows and user management to your **Rails**, **Sinatra** or **Rack** app.

[Userbin](https://userbin.com) provides a set of login, signup, and password reset forms that drop right into your application without any need of styling or writing markup. Connect your users via traditional logins or third party social networks. We take care of linking accounts across networks, resetting passwords, and keeping everything safe and secure. [Create a free account](https://userbin.com) to start accepting users in your application.

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

    In a Rails app, put the following code into a new file at `config/initializers/userbin.rb`

    ```ruby
    Userbin.configure do |config|
      config.app_id = "YOUR_APP_ID"
      config.api_secret = "YOUR_API_SECRET"
      config.restricted_path = "/admin"
    end
    ```

    If you don't configure the `app_id` and `api_secret`, the Userbin module will read the `USERBIN_APP_ID` and `USERBIN_API_SECRET` environment variables. This may come in handy on Heroku.
    
    Set up your `restricted_path` to which users will be redirected on a successful login. Browsing to this path or a sub-path will require the user to login. Logging out redirects the user back to the root path.

3.  **Rack/Sinatra apps only**: Activate the Userbin Rack middleware

    ```ruby
    use Userbin::Authentication
    ```
    
That's it! People are now able sign up and log in to your application.

Usage
-----

### Signup, login and logout

NOTE: To make installation as easy as possible, markup required for the Userbin UI are automatically inserted before the closing &lt;/body&gt; and &lt;/head&gt; tags in your HTML. It is therefore important that these tags are present on all pages where you want to use the links below.

These links will open up the [Userbin Widget](https://userbin.com/docs/javascript#widget) with either the login or signup form.

```html
<!-- put this on a public page -->
<a class="ub-login">Log in</a>
or
<a class="ub-signup">Sign up</a>
```

The logout link will clear the session and redirect the user back to your root path:

```html
<!-- put this on a restricted page -->
<a class="ub-logout">Log out</a>
```

See the [Javascript reference](https://userbin.com/docs/javascript#markup) for more info on this markup.

### The current user

Userbin keeps track of the currently logged in user:

```erb
Welcome to your account, <%= Userbin.user.email %>
```

To check if a user is logged in, use the following helper:

```erb
<% if Userbin.authenticated? %>
  You are logged in!
<% end %>
```

Documentation
-------------
For complete documentation go to [userbin.com/docs](https://userbin.com/docs)

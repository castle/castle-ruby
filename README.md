Userbin Ruby gem
================

Installation
------------

Begin with signing up at [https://userbin.com](https://userbin.com) to obtain
your App ID and API secret.

For simplicity’s sake, we will use the [Sinatra](http://www.sinatrarb.com/) framework. Start by installing Userbin and Sinatra:

```bash
$ gem install sinatra userbin
```

Now create a file called app.rb, require the gems and configure Userbin.

Set up your restricted path to which users will be redirected on a successful logins. Browsing to this path or a sub-path will require the user to login. Logging out redirects the user back to the root path.

```ruby
# app.rb
require "sinatra"
require "userbin"

Userbin.app_id = "15_DIGIT_APP_ID"
Userbin.api_secret = "32_BYTE_API_SECRET"

use Userbin::Authentication, restricted_path: '/admin'
```

That's it! People are now able sign up and log in to your application.

Usage
-----

### Signup, login and logout

To make installation as easy as possible, markup required for the Userbin UI are automatically inserted before the closing &lt;/body&gt; and &lt;/head&gt; tags in your HTML. It is therefore important that these tags are present on all pages where you want to use the links below.

These links will open up the [Userbin Widget](https://userbin.com/docs/javascript#widget) with either the login or signup form.

```html
<!-- put this on a public page -->
<a class="ub-login">Login</a>
or
<a class="ub-signup">Signup</a>
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

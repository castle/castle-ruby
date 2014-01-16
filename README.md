[![Build Status](https://travis-ci.org/userbin/userbin-ruby.png)](https://travis-ci.org/userbin/userbin-ruby)
[![Gem Version](https://badge.fury.io/rb/userbin.png)](http://badge.fury.io/rb/userbin)
[![Dependency Status](https://gemnasium.com/userbin/userbin-ruby.png)](https://gemnasium.com/userbin/userbin-ruby)

# Rails SDK for Userbin


[Userbin](https://userbin.com) is the easiest way to setup, use and maintain a secure user authentication system for both your web and mobile apps, while keeping the users in your own database.

Userbin provides a set of login, signup, and password reset forms that drop right into your application without any need of styling or writing markup. Connect your users via traditional logins or third party social networks. We take care of linking accounts across networks, resetting passwords and sending out necessary emails, while keeping everything safe and secure.

[Create a free account](https://userbin.com) at Userbin to start accepting users in your application.



## Installation and configuration

Add the `userbin` gem to your `Gemfile`

```ruby
gem "userbin"
```

Install the gem

```bash
bundle install
```

Create `config/initializers/userbin.rb` and configure your credentials.

```ruby
Userbin.configure do |config|
  config.app_id = "YOUR_APP_ID"
  config.api_secret = "YOUR_API_SECRET"
end
```

> If you don't configure the `app_id` and `api_secret`, the Userbin module will read the `USERBIN_APP_ID` and `USERBIN_API_SECRET` environment variables.

Implement getter and setter for your user model. For more information about the available attributes in the profile see the [Userbin profile](https://userbin.com/docs/profile) documentation.

```ruby
config.find_user = -> (userbin_id) do
  User.find_by_userbin_id(userbin_id)
end

# will be called when a user signs up
config.create_user = -> (profile) do
  User.create! do |user|
    user.userbin_id = profile.id
    user.email      = profile.email
    user.photo      = profile.image
  end
end
```

Migrate your users to include a reference to the Userbin profile:

```bash
rails g migration AddUserbinIdToUsers userbin_id:integer:index
rake db:migrate
```


## Authenticating users

  Userbin keeps track of the currently logged in user which can be accessed through `current_user` in controllers, views, and helpers. This automatically taps into libraries such as the authorization library [CanCan](https://github.com/ryanb/cancan).

```erb
<% if current_user %>
  <%= current_user.email %>
<% else %>
  Not logged in
<% end %>
```

To set up a controller with user authentication, just add this `before_filter`:

```ruby
class ArticlesController < ApplicationController
  before_filter :authorize!

  def index
    current_user.articles
  end
end
```

> You can always access the [Userbin profile](https://userbin.com/docs/profile) for the logged in user as `current_profile` when you need to access information that you haven't persisted in your user model.


## Forms

Once you have set up authentication it's time to choose among the different ways of integrating Userbin into your application.

### Ready-made forms

The easiest and fastest way to integrate login and signup forms is to use the Userbin Widget, which provides a set of ready-made views which can be customized to blend in with your current user interface. These views open up in a popup, and on mobile browsers they open up a new window tailored for smaller devices.

`rel` specifies action; possible options are `login` and `logout`.

```html
<a href="/account" rel="login">Log in</a>
<a href="/account" rel="signup">Sign up</a>
```

### Social buttons

Instead of signing up your users with a username and password, you can offer them to connect with a social identity like Facebook or LinkedIn. To use these button you must first configure your social identiy providers from the [dashboard](https://userbin.com/dashboard). It is also possible to connect a social identity to an already logged in user and the two accounts will be automatically linked.

`rel` determines action. If the user didn't exist before, it's created, otherwise it's logged in.

```html
<a href="/account" rel="connect-facebook">Connect with Facebook</a>
<a href="/account" rel="connect-linkedin">Connect with LinkedIn</a>
```

### Custom forms

The ready-made forms are fairly high level, so you might prefer to use Userbin with your own markup to get full control over looks and behavior.

If you create a form with `name` set to `login` or `signup`, the user will be sent to the URL specified by `action` after being successfully processed at Userbin.

Inputs with name `email` and `password` are processed, others are ignored.

If you add an element with the class `error-messages`, it will be automatically set to `display: block` and populated with a an error message when something goes wrong. So make sure to it is `display: hidden` by default.

```html
<form action="/account" name="signup">
  <span class="error-messages"></span>
  <div class="row">
    <label>E-mail</label>
    <input name="email" type="text"></input>
  </div>
  <div class="row">
    <label>Password</label>
    <input name="password" type="password"></input>
  </div>
  <button type="submit">Sign up</button>
</form>
```

### Log out

Clears the session and redirects the user to the specified URL.

```html
<a href="/" rel="logout">Log out</a>
```


## Further configuration

### Skip script injection

By default, the Userbin middleware will automatically insert a `<script>` tag before the closing `</body>` in your HTML files in order to handle forms, sessions and user tracking. This script loads everything asynchronously, so it won't affect your page load speed. However if you want to have control of this procedure, set `skip_script_injection` to true and insert the `<script>` tag yourself. To do that, checkout the [Userbin.js configuration guide](https://userbin.com/docs/javascript#configuration).

```ruby
config.skip_script_injection = true
```

## Admin dashboard

With Userbin you get an admin dashboard out of the box.

- Invite, update, remove and ban users
- Log in as any of your users for debugging
- Configure user validation, access rights and login methods
- See who is using your web or mobile app in real-time.
- Customize copy and appearance of your transactional emails.


## More documentation

For complete documentation go to [userbin.com/docs](https://userbin.com/docs)

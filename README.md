# Authkick

Lightweight authentication for OmniAuth

:bangbang: Not ready for production use

## Usage

Authkick provides four methods:

```ruby
sign_in(user)
sign_out
current_user
signed_in?
```

By default, users are remembered when returning for convenience.

```ruby
sign_in(user, remember: 1.year) # default
sign_in(user, remember: false) # log out when browser is closed
```

## Installation

First, select an OmniAuth strategy (or a few).

Add it to your Gemfile

```ruby
gem "authkick"
gem "omniauth-google-apps"
```

and create an initializer.

```ruby
# config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_apps
end
```

Add `uid` and `provider` fields - both strings - to your `User` model.

Next, create a `SessionsController` to manage the sign in and sign out actions.

```ruby
# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  # prevent CSRF warnings
  skip_before_filter :verify_authenticity_token, only: [:create]

  def create
    auth = request.env["omniauth.auth"]
    user = User.where(provider: auth["provider"], uid: auth["uid"])
            .first_or_create!(name: auth["info"]["name"])
    sign_in user
    redirect_to root_path
  end

  def destroy
    sign_out
    redirect_to root_path
  end

end
```

And hook up the routes

```ruby
# config/routes.rb
post "/auth/:provider/callback" => "sessions#create"
get "sign_out", :controller => "sessions", action: "destroy"
```

You now have authentication without the magic.

To require authentication before an action, add:

```ruby
# app/controllers/application_controller.rb
def authenticate!
  redirect_to "/auth/facebook" if !signed_in?
end
```

And do

```ruby
before_action :authenticate!
```

## Important

Protect your users from [Firesheep](http://en.wikipedia.org/wiki/Firesheep) - use https. In Rails, use:

```ruby
# config/environments/production.rb
config.force_ssl = true
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "authkick"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

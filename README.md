# Cubism
[![Twitter follow](https://img.shields.io/twitter/follow/julian_rubisch?style=social)](https://twitter.com/julian_rubisch)

Lightweight Resource-Based Presence Solution with CableReady

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Usage](#usage)
- [Installation](#installation)
- [Manual Installation](#manual-installation)
- [Contributing](#contributing)
- [License](#license)
- [Contributors](#contributors)

## Usage

### Prepare your User Model
In your app's `User` model, include `Cubism::User` and set up a safelist of exposed attributes:

```rb
class User < ApplicationRecord
  include Cubism::User
  self.cubicle_attributes = %i[email id]

  # ...
end
```

### Track Present Users in your Models
In the models you'd like to track presence for, include the `Cubism::Presence` concern:

```rb
class Project < ApplicationRecord
  include Cubism::Presence
end
```

### Set Up the Cubicle Template

Using the `cubicle_for` helper, you can set up a presence indicator. It will

1. subscribe to the respective resource, and
2. accept a "template" using the attributes safelisted above. Elements marked with `data-cubicle-attribute=` will have their `innerHTML` replaced by Cubism.

```erb
<%= cubicle_for @project do %>
  <span class="avatar">
    <span data-cubicle-attribute="email"></span>
  </span>
<% end %>
```

Note that this template will simply be repeated for every user that's in the `@project`s `present_users` set.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'cubism'
```

And then execute:
```bash
$ bundle
```

After `bundle`, install the Javascript library:

```bash
$ bin/yarn add @minthesize/cubism
```

### Kredis

This gem uses [kredis](https://github.com/rails/kredis) under the hood, so be sure to follow their [installation instructions](https://github.com/rails/kredis#installation). In other words, provide a Redis instance and configure it in `config/redis/shared.yml`.

### Javascript

In your app's Javascript entrypoint (e.g. `app/javascript/packs/application.js`) import and initialize `CableReady` (cubism will make use of the injected ActionCable consumer):

```js
import CableReady from "cable_ready";
import "@minthesize/cubism";

CableReady.initialize({ consumer });
```


## Contributing

### Get local environment setup

Below are a set of instructions that may help you get a local development environment working

```sh
# Get the gem/npm package source locally
git clone cubism
cd cubism/javascript
yarn install # install all of the npm package's dependencies
yarn link # set the local machine's cubism npm package's lookup to this local path

# Setup a sample project and edit Gemfile to point to local gem
# (e.g. `gem "cubism", path: "../cubism"`)
# yarn link @stimulus_reflex/cubism


# Do your work, Submit PR, Profit!


# To stop using your local version of cubism
# change your Gemfile back to the published (e.g. `gem "cubism"`)
cd path/to/cubism/javascript
# Stop using the local npm package
yarn unlink

# Instruct your project to reinstall the published version of the npm package
cd path/to/project
yarn install --force
```

### Release

1. Update the version numbers in `javascript/package.json` and `lib/cubism/version.rb`
2. `git commit -m "Bump version to x.x.x"`
3. Run `bundle exec rake build`
4. Run `bundle exec rake release`
5. `cd javascript && npm publish --access public`

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Contributors

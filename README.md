# Cubism
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->
[![Twitter follow](https://img.shields.io/twitter/follow/julian_rubisch?style=social)](https://twitter.com/julian_rubisch)

Lightweight Resource-Based Presence Solution with CableReady

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Usage](#usage)
- [Installation](#installation)
- [API](#api)
- [Gotchas](#gotchas)
- [Contributing](#contributing)
- [License](#license)
- [Contributors](#contributors)

## Usage

### Prepare your User Model
In your app's `User` model, include `Cubism::User`:

```rb
class User < ApplicationRecord
  include Cubism::User

  # ...
end
```

### Track Present Users in your Models
In the models you'd like to track presence for, include the `Cubism::Presence` concern:

```rb
class Project < ApplicationRecord
  include Cubism::Presence

  # ...
end
```

### Set Up the Cubicle Template

Using the `cubicle_for` helper, you can set up a presence indicator. It will

1. subscribe to the respective resource, and
2. render a block which is passed the list of present `users`:

```erb
<%= cubicle_for @project, current_user do |users| %>
  <%= users.map(&:username).join(", ")
<% end %>
```

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

## API

The `cubicle_for` helper accepts the following options as keyword arguments:

- `exclude_current_user (true|false)`: Whether or not to exclude the current user from the list of present users broadcasted to the view. Useful e.g. for "typing..." indicators.
- `appear_trigger`: JavaScript event names (e.g. `["focus", "debounced:input]`) to use. (Can also be a singular string, which will be converted to an array). The default is `:connect`, i.e. register a user as "appeared"/"present" when the element connects to the DOM.
- `disappear_trigger`: a JavaScript event name (e.g. `:blur`) to use. (Can also be a singular string, which will be converted to an array). The default is `:disconnect`, i.e. remove a user form the present users list when the element disconnects from the DOM.
- `trigger_root`: a CSS selector to attach the appear/disappear events to. Defaults to the `cubicle-element` itself.
- `html_options` are passed to the TagBuilder.

## Gotchas

### Usage with ViewComponent

Currently there's a bug in VC resulting in the `capture` helper not working correctly (https://github.com/github/view_component/pull/974). The current workaround is to assign a slot in your component and render the presence list from outside:

```rb
class MyComponent < ViewComponent::Base
  renders_one :presence_list

  # ...
end
```

```erb
<%= render MyComponent.new do |c| %>
  <% c.presence_list do %>
    <%= cubicle_for @project, current_user do |users| %>
      ...
    <% end %>
  <% end %>
<% end %>
```

## Contributing

### Get local environment setup

Below are a set of instructions that may help you get a local development environment working

```sh
# Get the gem/npm package source locally
git clone https://github.com/julianrubisch/cubism
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
5. Run `npm publish --access public`

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="http://www.minthesize.com"><img src="https://avatars.githubusercontent.com/u/4352208?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Julian Rubisch</b></sub></a><br /><a href="https://github.com/julianrubisch/cubism/commits?author=julianrubisch" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

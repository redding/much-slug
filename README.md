# MuchSlug

Friendly, human-readable identifiers for database records.

## Usage

## Active Record

```ruby
require "much-slug/activerecord"

class ProjectRecord < ApplicationRecord
  self.table_name = "projects"

  include MuchSlug::ActiveRecord
  has_slug({
    :source       => proc{ "#{self.id}-#{self.abbrev}" },
    :preprocessor => :upcase
  })
  before_update :reset_slug, :if => :abbrev_changed?

  # ...
end
```

## Sequel

TODO

## Installation

Add this line to your application's Gemfile:

    gem 'much-slug'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install much-slug

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# MuchSlug

Friendly, human-readable identifiers for database records.

## Usage

MuchSlug creates derived slug values on database records. Typically this means deriving the slug value from record attributes and syncing/caching that value in a dedicated field on the record.

### ActiveRecord

Given a `:slug` field on a record:

```ruby
class AddSlugToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column(:projects, :slug, :string, index: { unique: true })
  end
end
```

Mix-in `MuchSlug::ActiveRecord` and configure:

```ruby
require "much-slug/activerecord"

class ProjectRecord < ApplicationRecord
  self.table_name = "projects"

  include MuchSlug::ActiveRecord
  has_slug(
    source: -> { "#{self.id}-#{self.name}" },
  )

  # ...
end
```

The record will save slug values as it is saved:

```ruby
project = ProjectRecord.last
project.id   # => 123
project.name # => "Sprockets 2.0"
project.slug # => nil

# slug values are updated late-bound after record saves
project.save
project.slug # => "123-Sprockets-2-0"

project.name = "Widgets For Me"
project.slug # => "123-Sprockets-2-0"
project.save
project.slug # => "123-Widgets-For-Me"

# new Projects also have their slugs assigned once they are saved
project = Project.new(name: "Do The Things")
project.slug # => nil
project.save!
project.slug # => "124-Do-The-Things"
```

### Notes

#### Attribute

By default, the record attribute for a slug is `"slug"`. You can override this when configuring slugs:

```ruby
require "much-slug/activerecord"

class ProjectRecord < ApplicationRecord
  self.table_name = "projects"

  include MuchSlug::ActiveRecord
  has_slug(
    source: -> { "#{self.id}-#{self.name}" },
  )
  has_slug(
    attribute: :full_slug
    source:    -> { "#{self.id}-#{self.full_name}" },
  )

  # ...
end
```

#### Preprocessor

By default, MuchSlug doesn't pre-process the slug value source before generating the slug value. You can specify a custom pre-processor by passing any Proc-like object:

```ruby
require "much-slug/activerecord"

class ProjectRecord < ApplicationRecord
  self.table_name = "projects"

  include MuchSlug::ActiveRecord
  has_slug(
    source:       -> { "#{self.id}-#{self.name}" },
    preprocessor: :downcase
  )
  has_slug(
    attribute:    :full_slug
    source:       -> { "#{self.id}-#{self.full_name}" },
    preprocessor: -> { |source_value| source_value[0..30] }
  )

  # ...
end
```

#### Separator

MuchSlug replaces any non-word characters with a separator. This helps make slugs URL-friendly. By default, MuchSlug uses `"-"` for the separator. You can specify a custom separator value when configuring slugs:

```ruby
require "much-slug/activerecord"

class ProjectRecord < ApplicationRecord
  self.table_name = "projects"

  include MuchSlug::ActiveRecord
  has_slug(
    source:    -> { "#{self.id}.#{self.name}" },
    separator: "."
  )

  # ...
end

project = ProjectRecord.last
project.id   # => 123
project.name # => "Sprockets 2.0"
project.save
project.slug # => "123.Sprockets.2.0"
```

#### Allowing Underscores

By default, MuchSlug doesn't allow underscores in source values and treats them like non-word characters. This means it replaces underscores with the separator. You can override this to allow underscores when configuring slugs:

```ruby
require "much-slug/activerecord"

class ProjectRecord < ApplicationRecord
  self.table_name = "projects"

  include MuchSlug::ActiveRecord
  has_slug(
    source: -> { "#{self.id}-#{self.name}" }
  )
  has_slug(
    attribute:         :full_slug
    source:            -> { "#{self.id}-#{self.full_name}" },
    allow_underscores: true

  # ...
end

project = ProjectRecord.last
project.id        # => 123
project.name      # => "SP_2.0"
project.full_name # => "Sprockets_2.0"
project.save
project.slug      # => "123-SP-2-0"
project.full_slug # => "123-Sprockets_2-0"
```

#### Manual Slug Updates

Slugs are updated anytime a record is saved with changes that affect the slug. If you want an explicit, intention-revealing way to update the slugs manually, use `MuchSlug.update_slugs`:

```ruby
project = ProjectRecord.last
project.id   # => 123
project.name # => "Sprockets 2.0"

MuchSlug.update_slugs(project)
project.slug # => "123-Sprockets-2-0"
```

## Installation

Add this line to your application's Gemfile:

    gem "much-slug"

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

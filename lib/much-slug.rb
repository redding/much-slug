# frozen_string_literal: true

require "much-slug/activerecord"
require "much-slug/has_slug_registry"
require "much-slug/slug"
require "much-slug/version"

module MuchSlug
  def self.default_attribute
    "slug"
  end

  def self.default_preprocessor
    :to_s
  end

  def self.default_separator
    "-"
  end

  def self.default_allow_underscores
    false
  end

  def self.update_slugs(record)
    record.send("much_slug_has_slug_update_slug_values")
    true
  end

  def self.has_slug_changed_slug_values(record)
    record.class.much_slug_has_slug_registry.each do |attribute, entry|
      # ArgumentError: no receiver given` raised when calling `instance_exec`
      # on non-lambda Procs, specifically e.g :downcase.to_proc.
      # Can't call `instance_eval` on stabby lambdas b/c `instance_eval` auto
      # passes the receiver as the first argument to the block and stabby
      # lambdas may not expect that and will ArgumentError.
      slug_source_value =
        if entry.source_proc.lambda?
          record.instance_exec(&entry.source_proc)
        else
          record.instance_eval(&entry.source_proc)
        end

      slug_value =
        Slug.new(
          slug_source_value,
          preprocessor:      entry.preprocessor_proc,
          separator:         entry.separator,
          allow_underscores: entry.allow_underscores,
        )
      next if record.public_send(attribute) == slug_value
      yield attribute, slug_value
    end
  end
end

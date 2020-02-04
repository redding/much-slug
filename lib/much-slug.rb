require "much-slug/version"
require "much-slug/has_slug_registry"
require "much-slug/slug"

module MuchSlug
  def self.default_attribute
    "slug"
  end

  def self.default_preprocessor
    :to_s
  end

  def self.default_separator
    "-".freeze
  end

  def self.default_allow_underscores
    true
  end

  def self.has_slug_changed_slug_values(record_instance)
    record_instance.class.much_slug_has_slug_registry.each do |attribute, entry|
      slug_source_value = record_instance.instance_eval(&entry.source_proc)

      slug_value =
        Slug.new(
          slug_source_value,
          preprocessor:      entry.preprocessor_proc,
          separator:         entry.separator,
          allow_underscores: entry.allow_underscores
        )
      next if record_instance.send(attribute) == slug_value
      yield attribute, slug_value
    end
  end
end

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

  def self.reset_slug(record_instance, attribute)
    attribute ||= self.default_attribute
    record_instance.send("#{attribute}=", nil)
  end

  def self.has_slug_generate_slugs(record_instance)
    record_instance.class.much_slug_has_slug_registry.each do |attribute, entry|
      slug_source = record_instance.send(attribute)
      if slug_source.to_s.empty?
        slug_source = record_instance.instance_eval(&entry.source_proc)
      end

      generated_slug =
        Slug.new(
          slug_source,
          preprocessor:      entry.preprocessor_proc,
          separator:         entry.separator,
          allow_underscores: entry.allow_underscores
        )
      next if record_instance.send(attribute) == generated_slug
      record_instance.send("#{attribute}=", generated_slug)
      yield attribute, generated_slug
    end
  end
end

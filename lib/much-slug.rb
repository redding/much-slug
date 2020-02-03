require "much-slug/version"
require "much-slug/configs"
require "much-slug/slug"

module MuchSlug
  def self.default_attribute
    :slug
  end

  def self.default_preprocessor
    :to_s
  end

  def self.default_separator
    "-".freeze
  end

  def self.set_has_slug(configs, options)
    raise(ArgumentError, "a source must be provided") unless options[:source]

    (options[:attribute] || self.default_attribute).to_sym.tap do |a|
      configs[a].merge!({
        :source_proc       => options[:source].to_proc,
        :preprocessor_proc => (options[:preprocessor] || self.default_preprocessor).to_proc,
        :separator         => options[:separator] || self.default_separator,
        :allow_underscores => !!options[:allow_underscores]
      })
    end
  end

  def self.reset_slug(record_instance, attribute)
    attribute ||= self.default_attribute
    record_instance.send("#{attribute}=", nil)
  end

  def self.has_slug_generate_slugs(record_instance)
     record_instance.class.much_slug_has_slug_configs.each do |attr_name, config|
      if record_instance.send(attr_name).to_s.empty?
        slug_source = record_instance.instance_eval(&config[:source_proc])
      else
        slug_source = record_instance.send(attr_name)
      end

      generated_slug = Slug.new(slug_source, {
        :preprocessor      => config[:preprocessor_proc],
        :separator         => config[:separator],
        :allow_underscores => config[:allow_underscores]
      })
      next if record_instance.send(attr_name) == generated_slug
      record_instance.send("#{attr_name}=", generated_slug)
      yield attr_name, generated_slug
    end
  end
end

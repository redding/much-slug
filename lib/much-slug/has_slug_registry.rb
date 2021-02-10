# frozen_string_literal: true

require "much-slug"

module MuchSlug; end

class MuchSlug::HasSlugRegistry < ::Hash
  def initialize
    super(){ |h, k| h[k] = Entry.new }
  end

  def register(
        attribute:,
        source:,
        preprocessor:,
        separator:,
        allow_underscores:)
    attribute         = (attribute || MuchSlug.default_attribute).to_s
    source_proc       = source.to_proc
    preprocessor_proc = (preprocessor || MuchSlug.default_preprocessor).to_proc
    separator ||= MuchSlug.default_separator
    allow_underscores =
      if allow_underscores.nil?
        MuchSlug.default_allow_underscores
      else
        !!allow_underscores
      end

    entry = self[attribute]
    entry.source_proc       = source_proc
    entry.preprocessor_proc = preprocessor_proc
    entry.separator         = separator
    entry.allow_underscores = allow_underscores

    attribute
  end

  def copy_from(has_slug_registry)
    has_slug_registry.each do |attribute, entry|
      self[attribute] = entry.dup
    end
  end

  Entry =
    Struct.new(
      :source_proc,
      :preprocessor_proc,
      :separator,
      :allow_underscores,
    )
end
